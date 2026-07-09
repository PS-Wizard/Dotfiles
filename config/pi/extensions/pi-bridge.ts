import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, getAgentDir } from "@earendil-works/pi-coding-agent";
import * as crypto from "node:crypto";
import * as fs from "node:fs";
import * as net from "node:net";
import * as path from "node:path";

const SOCKETS_DIR = "/tmp/pi-bridge-sessions";
const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;

type ThinkingLevel = (typeof THINKING_LEVELS)[number];

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
    if (!currentCtx || currentJob) {
      return;
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
    busy = true;
    writeMetadata();

    try {
      await applyModel(job.model);
      if (job.thinking) {
        pi.setThinkingLevel(job.thinking);
        currentThinking = pi.getThinkingLevel() as ThinkingLevel;
        writeMetadata();
      }
      await pi.sendUserMessage(job.prompt);
    } catch (error) {
      finishCurrentJob(false, error instanceof Error ? error.message : String(error));
      scheduleProcessQueue();
    }
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

    if (queueRetryTimer) {
      clearTimeout(queueRetryTimer);
      queueRetryTimer = null;
    }

  function cleanup() {
    if (server) {
      server.close();
      server = null;
    }

    if (socketPath) {
      try {
        fs.unlinkSync(socketPath);
      } catch {}
    }

    if (infoPath) {
      try {
        fs.unlinkSync(infoPath);
      } catch {}
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    cleanup();
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
    refreshState(ctx);
    busy = true;
    writeMetadata();
  });

  pi.on("agent_end", async (_event, ctx) => {
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
    refreshState(ctx);
    currentModel = modelKey(event.model);
    writeMetadata();
  });

  pi.on("thinking_level_select", async (event, ctx) => {
    refreshState(ctx);
    currentThinking = event.level as ThinkingLevel;
    writeMetadata();
  });

  pi.on("session_shutdown", async () => {
    cleanup();
  });

  process.on("exit", cleanup);
}
