import { randomBytes } from "node:crypto";
import { chmod, mkdir, readdir, readFile, rename, unlink, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join, sep } from "node:path";
import net, { type Server, type Socket } from "node:net";
import { Type } from "typebox";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const PROTOCOL = 1;
const NAME = /^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$/;
const MAX_PROMPT = 64 * 1024;
const MAX_LINE = MAX_PROMPT + 1024;
const TIMEOUT = 1500;
const configDir = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
const root = join(configDir, "pi-communicate");
const sessionsDir = join(root, "sessions");
const socketsDir = join(root, "sockets");

type Descriptor = {
	protocol: number;
	name: string;
	socketPath: string;
	secret: string;
	pid: number;
	sessionId: string;
	cwd: string;
	updatedAt: number;
};

type Request = { protocol: number; secret: string; op: "probe" | "prompt"; prompt?: string };
type Response = { protocol: number; ok: boolean; error?: string; idle?: boolean };

function validName(name: string): boolean {
	return NAME.test(name);
}

function descriptorPath(name: string): string {
	return join(sessionsDir, `${name}.json`);
}

function isDescriptor(value: unknown): value is Descriptor {
	if (!value || typeof value !== "object") return false;
	const d = value as Record<string, unknown>;
	return (
		d.protocol === PROTOCOL &&
		typeof d.name === "string" &&
		validName(d.name) &&
		typeof d.socketPath === "string" &&
		d.socketPath.startsWith(`${socketsDir}${sep}`) &&
		typeof d.secret === "string" &&
		/^[a-f0-9]{32,}$/i.test(d.secret) &&
		typeof d.pid === "number" &&
		Number.isInteger(d.pid) &&
		d.pid > 0 &&
		typeof d.sessionId === "string" &&
		typeof d.cwd === "string" &&
		typeof d.updatedAt === "number" &&
		Number.isFinite(d.updatedAt)
	);
}

async function ensureDirectories(): Promise<void> {
	for (const dir of [root, sessionsDir, socketsDir]) {
		await mkdir(dir, { recursive: true, mode: 0o700 });
		await chmod(dir, 0o700);
	}
}

async function readDescriptor(name: string): Promise<Descriptor | undefined> {
	try {
		const value: unknown = JSON.parse(await readFile(descriptorPath(name), "utf8"));
		return isDescriptor(value) && value.name === name ? value : undefined;
	} catch {
		return undefined;
	}
}

async function writeDescriptor(descriptor: Descriptor): Promise<void> {
	const temp = join(sessionsDir, `.${descriptor.name}.${process.pid}.${randomBytes(6).toString("hex")}.tmp`);
	try {
		await writeFile(temp, JSON.stringify(descriptor), { encoding: "utf8", mode: 0o600, flag: "wx" });
		await chmod(temp, 0o600);
		await rename(temp, descriptorPath(descriptor.name));
	} finally {
		await unlink(temp).catch(() => undefined);
	}
}

async function removeIfSame(descriptor: Descriptor): Promise<void> {
	const current = await readDescriptor(descriptor.name);
	if (current?.socketPath === descriptor.socketPath && current.secret === descriptor.secret) {
		await unlink(descriptorPath(descriptor.name)).catch(() => undefined);
	}
}

function request(descriptor: Descriptor, op: Request["op"], prompt?: string): Promise<Response> {
	return new Promise((resolve, reject) => {
		const socket = net.createConnection({ path: descriptor.socketPath });
		let buffer = "";
		let done = false;
		const finish = (error?: Error, response?: Response) => {
			if (done) return;
			done = true;
			clearTimeout(timer);
			socket.destroy();
			error ? reject(error) : resolve(response!);
		};
		const timer = setTimeout(() => finish(new Error("Delivery timed out")), TIMEOUT);
		socket.setEncoding("utf8");
		socket.once("connect", () => {
			socket.write(`${JSON.stringify({ protocol: PROTOCOL, secret: descriptor.secret, op, ...(prompt === undefined ? {} : { prompt }) })}\n`);
		});
		socket.on("data", (chunk: string) => {
			buffer += chunk;
			if (buffer.length > MAX_LINE) return finish(new Error("Invalid response"));
			const newline = buffer.indexOf("\n");
			if (newline < 0) return;
			try {
				const response: unknown = JSON.parse(buffer.slice(0, newline));
				if (!response || typeof response !== "object") throw new Error();
				const value = response as Response;
				if (value.protocol !== PROTOCOL || typeof value.ok !== "boolean") throw new Error();
				finish(value.ok ? undefined : new Error(value.error || "Delivery rejected"), value);
			} catch {
				finish(new Error("Invalid response"));
			}
		});
		socket.once("error", () => finish(new Error("Session is unreachable")));
	});
}

async function probe(descriptor: Descriptor): Promise<boolean> {
	try {
		await request(descriptor, "probe");
		return true;
	} catch {
		return false;
	}
}

export default function (pi: ExtensionAPI) {
	let server: Server | undefined;
	let socketPath: string | undefined;
	let secret: string | undefined;
	let sessionId: string | undefined;
	let registered: Descriptor | undefined;
	const clients = new Set<Socket>();

	function showName(ctx: ExtensionContext, name?: string): void {
		ctx.ui.setStatus("pi-communicate", name ? `session:${name}` : undefined);
		if (name) ctx.ui.setTitle(`pi - ${name}`);
	}

	async function unregister(ctx?: ExtensionContext): Promise<void> {
		if (registered) await removeIfSame(registered);
		registered = undefined;
		if (ctx) showName(ctx);
	}

	async function register(name: string, ctx: ExtensionContext): Promise<void> {
		if (!server || !socketPath || !secret || !sessionId) throw new Error("Communication is not ready");
		if (registered?.name !== name) await unregister();
		const previous = await readDescriptor(name);
		if (previous && (previous.socketPath !== socketPath || previous.secret !== secret)) {
			if (await probe(previous)) throw new Error(`Session name "${name}" is in use`);
			await removeIfSame(previous);
		}
		const descriptor: Descriptor = {
			protocol: PROTOCOL,
			name,
			socketPath,
			secret,
			pid: process.pid,
			sessionId,
			cwd: ctx.cwd,
			updatedAt: Date.now(),
		};
		await writeDescriptor(descriptor);
		registered = descriptor;
		showName(ctx, name);
	}

	async function deliver(target: string, prompt: string): Promise<void> {
		if (!validName(target)) throw new Error("Invalid session name");
		if (!prompt.trim()) throw new Error("Prompt is required");
		if (Buffer.byteLength(prompt, "utf8") > MAX_PROMPT) throw new Error("Prompt is too long");
		if (target === registered?.name) throw new Error("Cannot send to this session");
		const descriptor = await readDescriptor(target);
		if (!descriptor) throw new Error(`No session named "${target}"`);
		try {
			await request(descriptor, "prompt", prompt);
		} catch (error) {
			if (!(await probe(descriptor))) await removeIfSame(descriptor);
			throw error;
		}
	}

	async function status(target: string): Promise<"idle" | "running" | "unavailable"> {
		if (!validName(target)) return "unavailable";
		const descriptor = await readDescriptor(target);
		if (!descriptor) return "unavailable";
		try {
			const response = await request(descriptor, "probe");
			if (typeof response.idle !== "boolean") throw new Error("Invalid status");
			return response.idle ? "idle" : "running";
		} catch {
			await removeIfSame(descriptor);
			return "unavailable";
		}
	}

	async function liveSessions(): Promise<Descriptor[]> {
		let files: string[];
		try {
			files = await readdir(sessionsDir);
		} catch {
			return [];
		}
		const live: Descriptor[] = [];
		for (const file of files) {
			if (!file.endsWith(".json")) continue;
			const name = file.slice(0, -5);
			if (!validName(name)) continue;
			const descriptor = await readDescriptor(name);
			if (!descriptor) continue;
			if (await probe(descriptor)) live.push(descriptor);
			else await removeIfSame(descriptor);
		}
		return live.sort((a, b) => a.name.localeCompare(b.name));
	}

	async function handleClient(socket: Socket, ctx: ExtensionContext): Promise<void> {
		let buffer = "";
		const respond = (response: Response) => socket.end(`${JSON.stringify(response)}\n`);
		socket.setEncoding("utf8");
		socket.on("data", (chunk: string) => {
			buffer += chunk;
			if (buffer.length > MAX_LINE) {
				respond({ protocol: PROTOCOL, ok: false, error: "Message too large" });
				return;
			}
			const newline = buffer.indexOf("\n");
			if (newline < 0) return;
			void (async () => {
				try {
					const value: unknown = JSON.parse(buffer.slice(0, newline));
					const request = value as Partial<Request>;
					if (
						!value ||
						typeof value !== "object" ||
						request.protocol !== PROTOCOL ||
						request.secret !== secret ||
						(request.op !== "probe" && request.op !== "prompt")
					) {
						return respond({ protocol: PROTOCOL, ok: false, error: "Unauthorized" });
					}
					if (request.op === "probe") return respond({ protocol: PROTOCOL, ok: true, idle: ctx.isIdle() });
					if (typeof request.prompt !== "string" || !request.prompt.trim()) {
						return respond({ protocol: PROTOCOL, ok: false, error: "Prompt is required" });
					}
					if (Buffer.byteLength(request.prompt, "utf8") > MAX_PROMPT) {
						return respond({ protocol: PROTOCOL, ok: false, error: "Prompt is too long" });
					}
					if (ctx.isIdle()) pi.sendUserMessage(request.prompt);
					else pi.sendUserMessage(request.prompt, { deliverAs: "followUp" });
					respond({ protocol: PROTOCOL, ok: true });
				} catch {
					respond({ protocol: PROTOCOL, ok: false, error: "Delivery failed" });
				}
			})();
		});
	}

	pi.registerCommand("pi-communicate-set-session-title", {
		description: "Set this session's communication name",
		handler: async (args, ctx) => {
			const name = args.trim();
			if (!name) {
				ctx.ui.notify(registered ? `Session: ${registered.name}` : "Usage: /pi-communicate-set-session-title <name>", "info");
				return;
			}
			if (!validName(name)) {
				ctx.ui.notify("Invalid name: use up to 64 letters, numbers, ., _, or -", "error");
				return;
			}
			try {
				await register(name, ctx);
				pi.setSessionName(name);
				ctx.ui.notify(`Session named ${name}`, "info");
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Could not name session", "error");
			}
		},
	});

	pi.registerCommand("pi-send", {
		description: "Send a prompt to a named live Pi session",
		handler: async (args, ctx) => {
			const [target, ...parts] = args.trim().split(/\s+/);
			const prompt = parts.join(" ");
			if (!target || !prompt) {
				ctx.ui.notify("Usage: /pi-send <target> <prompt>", "error");
				return;
			}
			try {
				await deliver(target, prompt);
				ctx.ui.notify(`Sent to ${target}`, "info");
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Send failed", "error");
			}
		},
	});

	pi.registerCommand("pi-communicate-check-status", {
		description: "Check whether a named live Pi session is idle or running",
		handler: async (args, ctx) => {
			const target = args.trim();
			if (!target) {
				ctx.ui.notify("Usage: /pi-communicate-check-status <identifier>", "warning");
				return;
			}
			ctx.ui.notify(await status(target), "info");
		},
	});

	pi.registerCommand("pi-communicate-list-sessions", {
		description: "List live named Pi sessions",
		handler: async (_args, ctx) => {
			const sessions = await liveSessions();
			ctx.ui.notify(
				sessions.length
					? sessions.map((s) => `${s.name}${s.name === registered?.name ? " (current)" : ""} ${s.cwd}`).join("\n")
					: "No live named sessions",
				"info",
			);
		},
	});

	pi.registerShortcut("ctrl+n", {
		description: "Set this session's communication name",
		handler: async (ctx) => {
			if (!ctx.hasUI) return;
			const name = (await ctx.ui.input("Set session identifier:", registered?.name ?? "frontend"))?.trim();
			if (!name) return;
			if (!validName(name)) {
				ctx.ui.notify("Invalid name: use up to 64 letters, numbers, ., _, or -", "error");
				return;
			}
			try {
				await register(name, ctx);
				pi.setSessionName(name);
				ctx.ui.notify(`Session named ${name}`, "info");
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Could not name session", "error");
			}
		},
	});

	pi.registerTool({
		name: "pi_communicate",
		label: "Pi Communicate",
		description: "Send a prompt to another live named Pi session. This only confirms local delivery or queueing and does not wait for that session to complete work.",
		promptSnippet: "Send fire-and-forget prompts to other live named Pi sessions",
		promptGuidelines: ["Use pi_communicate when another named Pi session should act on a message."],
		parameters: Type.Object({
			target: Type.String({ description: "Live Pi session name" }),
			prompt: Type.String({ description: "Prompt to deliver" }),
		}),
		async execute(_toolCallId, params) {
			await deliver(params.target, params.prompt);
			return { content: [{ type: "text", text: `Delivered to ${params.target}; it may still be working.` }], details: {} };
		},
	});

	pi.registerTool({
		name: "pi_communicate_status",
		label: "Pi Communicate Status",
		description: "Check whether a named Pi session is idle, running, or unavailable.",
		promptSnippet: "Check whether another named Pi session is idle or running",
		promptGuidelines: ["Use pi_communicate_status to check a named Pi session without waiting for task completion."],
		parameters: Type.Object({
			target: Type.String({ description: "Pi session name" }),
		}),
		async execute(_toolCallId, params) {
			const state = await status(params.target);
			return { content: [{ type: "text", text: `${params.target}: ${state}` }], details: { state } };
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		await ensureDirectories();
		secret = randomBytes(32).toString("hex");
		sessionId = ctx.sessionManager.getSessionId();
		socketPath = join(socketsDir, `pi-${process.pid}-${randomBytes(6).toString("hex")}.sock`);
		await unlink(socketPath).catch(() => undefined);
		server = net.createServer((socket) => {
			clients.add(socket);
			socket.setTimeout(TIMEOUT, () => socket.destroy());
			socket.once("close", () => clients.delete(socket));
			void handleClient(socket, ctx).catch(() => socket.destroy());
		});
		await new Promise<void>((resolve, reject) => {
			server!.once("error", reject);
			server!.listen(socketPath, resolve);
		});
		await chmod(socketPath, 0o600);
		const name = pi.getSessionName();
		if (name && validName(name)) {
			try {
				await register(name, ctx);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Could not register session", "warning");
			}
		} else {
			showName(ctx);
		}
	});

	pi.on("session_info_changed", async (event, ctx) => {
		if (!event.name) return unregister(ctx);
		if (!validName(event.name)) {
			await unregister(ctx);
			ctx.ui.notify("Session name is not a communication identifier", "warning");
			return;
		}
		try {
			await register(event.name, ctx);
		} catch (error) {
			await unregister(ctx);
			ctx.ui.notify(error instanceof Error ? error.message : "Could not register session", "warning");
		}
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		await unregister(ctx);
		for (const client of clients) client.destroy();
		clients.clear();
		if (server) await new Promise<void>((resolve) => server!.close(() => resolve()));
		if (socketPath) await unlink(socketPath).catch(() => undefined);
		server = undefined;
		socketPath = undefined;
		secret = undefined;
		sessionId = undefined;
	});
}
