import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, getAgentDir } from "@earendil-works/pi-coding-agent";
import * as crypto from "node:crypto";
import * as fs from "node:fs";
import * as net from "node:net";
import * as path from "node:path";

const SOCKETS_DIR = "/tmp/pi-bridge-sessions";
const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;

// How long a handed-off job may sit while pi reports idle before we assume the
// send never produced an agent run (e.g. preflight failure) and recover, so a
// single bad send can never wedge the queue.
const STUCK_GRACE_MS = 6000;

// Subagents load extensions in this process; only the parent may own the socket.
const BRIDGE_OWNER = Symbol.for("pi-bridge.owner");
const bridgeGlobal = globalThis as typeof globalThis & { [BRIDGE_OWNER]?: symbol };

type ThinkingLevel = (typeof THINKING_LEVELS)[number];

// Mirror of pi's getSupportedThinkingLevels: which effort levels a given model
// actually exposes. Non-reasoning models only support "off"; otherwise a null
// in thinkingLevelMap hides a level, and xhigh/max require an explicit mapping.
function supportedThinkingLevels(model: {
  reasoning?: boolean;
  thinkingLevelMap?: Partial<Record<ThinkingLevel, string | null>>;
}): ThinkingLevel[] {
  if (!model.reasoning) {
    return ["off"];
  }
  return THINKING_LEVELS.filter((level) => {
    const mapped = model.thinkingLevelMap?.[level];
    if (mapped === null) {
      return false;
    }
    if (level === "xhigh" || level === "max") {
      return mapped !== undefined;
    }
    return true;
  });
}

type Job = {
  id: string;
  prompt: string;
  model?: string;
  thinking?: ThinkingLevel;
  enqueuedAt: string;
};

type SettingsShape = {
  enabledModels?: string[];
};

function cwdHash(cwd: string): string {
  return crypto.createHash("md5").update(cwd).digest("hex").slice(0, 12);
}

function modelKey(model: { provider: string; id: string }): string {
  return `${model.provider}/${model.id}`;
}

function escapeRegex(value: string): string {
  return value.replace(/[|\\{}()[\]^$+?.]/g, "\\$&");
}

function matchesPattern(value: string, pattern: string): boolean {
  if (pattern === value) {
    return true;
  }

  const regex = new RegExp(`^${escapeRegex(pattern).replace(/\*/g, ".*")}$`);
  if (regex.test(value)) {
    return true;
  }

  if (!pattern.includes("/")) {
    return regex.test(value.split("/").slice(1).join("/"));
  }

  return false;
}

function readJsonFile(filePath: string): SettingsShape {
  try {
    if (!fs.existsSync(filePath)) {
      return {};
    }
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as SettingsShape;
  } catch {
    return {};
  }
}

function loadEnabledModels(cwd: string): string[] {
  const globalSettings = readJsonFile(path.join(getAgentDir(), "settings.json"));
  const projectSettings = readJsonFile(path.join(cwd, CONFIG_DIR_NAME, "settings.json"));
  return projectSettings.enabledModels ?? globalSettings.enabledModels ?? [];
}

export default function (pi: ExtensionAPI) {
  const ownerToken = Symbol();
  let ownsBridge = false;
  let server: net.Server | null = null;
  let socketPath: string | null = null;
  let infoPath: string | null = null;
  let currentCtx: ExtensionContext | null = null;
  let startedAt = "";
  let queue: Job[] = [];
  let queueRetryTimer: ReturnType<typeof setTimeout> | null = null;
  let currentJob: Job | null = null;
  let currentModel = "";
  let currentThinking: ThinkingLevel = "high";
  let enabledModels: string[] = [];
  let modelThinkingLevels: Record<string, ThinkingLevel[]> = {};
  let jobStartedAt = 0;
  let lastFinishedJobId = "";
  let lastFinishedAt = "";
  let lastFinishedOk = true;
  let lastError = "";
  let busy = false;

  function metadata() {
    return {
      cwd: currentCtx?.cwd ?? "",
      pid: process.pid,
      socket_path: socketPath,
      info_path: infoPath,
      tmux_pane: process.env.TMUX_PANE ?? "",
      started_at: startedAt,
      current_model: currentModel,
      current_thinking: currentThinking,
      enabled_models: enabledModels,
      thinking_levels: THINKING_LEVELS,
      model_thinking_levels: modelThinkingLevels,
      busy,
      queue_length: (currentJob ? 1 : 0) + queue.length,
      current_job_id: currentJob?.id ?? "",
      queued_job_ids: queue.map((job) => job.id),
      last_finished_job_id: lastFinishedJobId,
      last_finished_at: lastFinishedAt,
      last_finished_ok: lastFinishedOk,
      last_error: lastError,
    };
  }

  function writeMetadata() {
    if (!infoPath) {
      return;
    }

    try {
      fs.mkdirSync(SOCKETS_DIR, { recursive: true });
      fs.writeFileSync(infoPath, JSON.stringify(metadata(), null, 2));
    } catch {}
  }

  function refreshState(ctx: ExtensionContext) {
    currentCtx = ctx;
    currentModel = ctx.model ? modelKey(ctx.model) : currentModel;
    currentThinking = pi.getThinkingLevel() as ThinkingLevel;

    const available = ctx.modelRegistry.getAvailable();
    const scoped = loadEnabledModels(ctx.cwd);
    if (scoped.length > 0) {
      enabledModels = available
        .filter((model) => scoped.some((pattern) => matchesPattern(modelKey(model), pattern)))
        .map((model) => modelKey(model));
    } else {
      enabledModels = available.map((model) => modelKey(model));
    }

    if (currentModel && !enabledModels.includes(currentModel)) {
      enabledModels.unshift(currentModel);
    }

    modelThinkingLevels = {};
    for (const model of available) {
      const key = modelKey(model);
      if (enabledModels.includes(key)) {
        modelThinkingLevels[key] = supportedThinkingLevels(model);
      }
    }

    writeMetadata();
  }

  async function applyModel(modelName?: string) {
    if (!modelName || !currentCtx || modelName === currentModel) {
      return true;
    }

    const slash = modelName.indexOf("/");
    if (slash <= 0) {
      return false;
    }

    const provider = modelName.slice(0, slash);
    const modelId = modelName.slice(slash + 1);
    const model = currentCtx.modelRegistry.find(provider, modelId);
    if (!model) {
      return false;
    }

    const ok = await pi.setModel(model);
    if (ok) {
      currentModel = modelName;
      writeMetadata();
    }
    return ok;
  }

  function scheduleProcessQueue(delay = 150) {
    if (queueRetryTimer) {
      return;
    }
    queueRetryTimer = setTimeout(() => {
      queueRetryTimer = null;
      void processQueue();
    }, delay);
  }

  function finishCurrentJob(ok: boolean, error = "") {
    lastFinishedJobId = currentJob?.id ?? "";
    lastFinishedAt = new Date().toISOString();
    lastFinishedOk = ok;
    lastError = error;
    currentJob = null;
    busy = currentCtx ? !currentCtx.isIdle() : false;
    writeMetadata();
  }

  async function processQueue() {
    if (!currentCtx) {
      return;
    }

    // A job is in flight: agent_settled will finish it. Watchdog: if pi has been
    // fully idle well past hand-off, the send never started an agent run (e.g. a
    // preflight failure whose rejection pi swallows), so recover instead of
    // wedging the whole queue.
    if (currentJob) {
      if (currentCtx.isIdle() && Date.now() - jobStartedAt > STUCK_GRACE_MS) {
        finishCurrentJob(false, "pi did not start the message");
      } else {
        scheduleProcessQueue();
        return;
      }
    }

    if (!currentCtx.isIdle()) {
      busy = true;
      writeMetadata();
      scheduleProcessQueue();
      return;
    }

    const job = queue.shift();
    if (!job) {
      busy = false;
      writeMetadata();
      return;
    }

    currentJob = job;
    jobStartedAt = Date.now();
    busy = true;
    writeMetadata();

    try {
      await applyModel(job.model);
      if (job.thinking) {
        pi.setThinkingLevel(job.thinking);
        currentThinking = pi.getThinkingLevel() as ThinkingLevel;
        writeMetadata();
      }
    } catch (error) {
      finishCurrentJob(false, error instanceof Error ? error.message : String(error));
      scheduleProcessQueue();
      return;
    }

    // deliverAs:"followUp" makes delivery race-proof: sent immediately when pi is
    // idle, queued behind in-flight work when it is streaming. Without it,
    // sendUserMessage throws "Agent is already processing" the instant pi went
    // busy between the isIdle() check and here — and pi's runtime swallows that
    // rejection, so the job silently vanished with the queue stuck forever.
    jobStartedAt = Date.now();
    pi.sendUserMessage(job.prompt, { deliverAs: "followUp" });
    // Keep polling so the watchdog can recover if no agent run/settle ever comes.
    scheduleProcessQueue();
  }

  function respond(conn: net.Socket, payload: unknown) {
    try {
      conn.write(JSON.stringify(payload) + "\n");
    } catch {}
  }

  function handleMessage(raw: string, conn: net.Socket) {
    try {
      const message = JSON.parse(raw) as { type?: string; id?: string; prompt?: string; model?: string; thinking?: ThinkingLevel };

      if (message.type === "ping") {
        respond(conn, { ok: true, type: "pong" });
        return;
      }

      if (message.type === "enqueue" && typeof message.id === "string" && typeof message.prompt === "string") {
        queue.push({
          id: message.id,
          prompt: message.prompt,
          model: message.model,
          thinking: message.thinking,
          enqueuedAt: new Date().toISOString(),
        });
        writeMetadata();
        void processQueue();
        respond(conn, { ok: true, type: "enqueued", id: message.id, position: queue.length + (currentJob ? 1 : 0) });
        return;
      }

      respond(conn, { ok: false, error: "Unknown command" });
    } catch (error) {
      respond(conn, { ok: false, error: error instanceof Error ? error.message : String(error) });
    }
  }

  function cleanup() {
    if (queueRetryTimer) {
      clearTimeout(queueRetryTimer);
      queueRetryTimer = null;
    }

    if (server) {
      server.close();
      server = null;
    }

    if (socketPath) {
      try {
        fs.unlinkSync(socketPath);
      } catch {}
      socketPath = null;
    }

    if (infoPath) {
      try {
        fs.unlinkSync(infoPath);
      } catch {}
      infoPath = null;
    }

    if (ownsBridge && bridgeGlobal[BRIDGE_OWNER] === ownerToken) {
      delete bridgeGlobal[BRIDGE_OWNER];
      process.off("exit", cleanup);
    }
    ownsBridge = false;
  }

  pi.on("session_start", async (_event, ctx) => {
    cleanup();
    if (bridgeGlobal[BRIDGE_OWNER]) {
      return;
    }
    bridgeGlobal[BRIDGE_OWNER] = ownerToken;
    ownsBridge = true;
    process.once("exit", cleanup);
    currentCtx = ctx;
    startedAt = new Date().toISOString();
    queue = [];
    currentJob = null;
    lastFinishedJobId = "";
    lastFinishedAt = "";
    lastFinishedOk = true;
    lastError = "";
    busy = false;

    fs.mkdirSync(SOCKETS_DIR, { recursive: true });
    const base = `${cwdHash(ctx.cwd)}-${process.pid}`;
    socketPath = path.join(SOCKETS_DIR, `${base}.sock`);
    infoPath = path.join(SOCKETS_DIR, `${base}.json`);

    try {
      fs.unlinkSync(socketPath);
    } catch {}

    server = net.createServer((conn) => {
      let buffer = "";
      conn.on("data", (chunk) => {
        buffer += chunk.toString();
        while (true) {
          const newline = buffer.indexOf("\n");
          if (newline === -1) {
            break;
          }
          const line = buffer.slice(0, newline).trim();
          buffer = buffer.slice(newline + 1);
          if (line !== "") {
            handleMessage(line, conn);
          }
        }
      });
      conn.on("error", () => {});
    });

    server.listen(socketPath, () => {
      refreshState(ctx);
    });
  });

  pi.on("agent_start", async (_event, ctx) => {
    if (!ownsBridge) {
      return;
    }
    refreshState(ctx);
    busy = true;
    writeMetadata();
  });

  // agent_end fires per low-level agent run and "may auto-retry or compact
  // afterward", so it is NOT job completion. agent_settled is the authoritative
  // "pi is fully done, nothing more will run" signal — finish the job there.
  pi.on("agent_settled", async (_event, ctx) => {
    if (!ownsBridge) {
      return;
    }
    refreshState(ctx);
    if (currentJob) {
      finishCurrentJob(true);
    } else {
      busy = false;
      writeMetadata();
    }
    scheduleProcessQueue();
  });

  pi.on("model_select", async (event, ctx) => {
    if (!ownsBridge) {
      return;
    }
    refreshState(ctx);
    currentModel = modelKey(event.model);
    writeMetadata();
  });

  pi.on("thinking_level_select", async (event, ctx) => {
    if (!ownsBridge) {
      return;
    }
    refreshState(ctx);
    currentThinking = event.level as ThinkingLevel;
    writeMetadata();
  });

  pi.on("session_shutdown", async () => {
    cleanup();
  });

}
