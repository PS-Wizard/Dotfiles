/**
 * Obsidian Command — /obsidian
 *
 * Registers the /obsidian slash command for working with a Personal
 * Knowledge Management vault.  The handler:
 *   1. Reads vault config (from PI_CODING_AGENT_DIR/obsidian-config.json)
 *   2. Captures a snapshot of the vault directory structure
 *   3. Builds a rich prompt with vault context, philosophy, template
 *   4. Sends it to the agent, which validates understanding first,
 *      then creates the note in the user's own words
 *
 * Usage:
 *   /obsidian write a new note about copy vs clone in rust. ...
 *   /obsidian i keep forgetting how self vs Self differ in rust ...
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync, existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { execSync } from "node:child_process";

function agentDir(): string {
  return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

interface ObsidianConfig {
  vaultPath: string;
  vaultName: string;
  noteTemplate: string;
  philosophy: string;
}

function loadConfig(): ObsidianConfig | null {
  const configPath = join(agentDir(), "obsidian-config.json");
  try {
    const raw = readFileSync(configPath, "utf-8");
    const cfg = JSON.parse(raw) as ObsidianConfig;
    if (!cfg.vaultPath || !cfg.philosophy || !cfg.noteTemplate) {
      console.error("[obsidian] Config missing required fields");
      return null;
    }
    return cfg;
  } catch (err) {
    console.error(`[obsidian] Failed to load config: ${err}`);
    return null;
  }
}

function getVaultStructure(vaultPath: string): string {
  try {
    if (!existsSync(vaultPath)) return "(vault path does not exist)";
    const out = execSync(
      `find "${vaultPath}" -not -path '*/.obsidian/*' -not -path '*/.git/*' -not -name '.git' | head -80`,
      { encoding: "utf-8", timeout: 5000 },
    );
    return out.trim();
  } catch {
    return "(could not list vault structure)";
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("obsidian", {
    description:
      "Create/manage Obsidian notes. Validates understanding first, then writes notes in your own words.",
    handler: async (args, ctx) => {
      const input = args.trim();
      if (!input) {
        ctx.ui.notify(
          "Usage: /obsidian <your note request or question>",
          "warning",
        );
        return;
      }

      // 1. Load config
      const config = loadConfig();
      if (!config) {
        ctx.ui.notify(
          "Config missing. Create $PI_CODING_AGENT_DIR/obsidian-config.json with vaultPath, philosophy, and noteTemplate.",
          "error",
        );
        return;
      }

      // 2. Ensure agent is idle before sending
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy. Wait for it to finish first.", "warning");
        return;
      }

      // 3. Get vault structure snapshot
      const vaultStructure = getVaultStructure(config.vaultPath);

      // 4. Build and send the rich prompt
      const prompt = buildPrompt(config, vaultStructure, input);
      ctx.ui.notify("📔 Sending to Obsidian workflow…", "info");
      pi.sendUserMessage(prompt);
    },
  });
}

function buildPrompt(
  config: ObsidianConfig,
  vaultStructure: string,
  userInput: string,
): string {
  return [
    `# 📔 Obsidian Note Creation`,
    ``,
    `## Vault Information`,
    `- **Vault**: ${config.vaultName}`,
    `- **Path**: \`${config.vaultPath}\``,
    ``,
    `## Note-taking Philosophy`,
    config.philosophy,
    ``,
    `## Note Template`,
    `Every note should use this structure (fill each section with the **user's own words**, not generic textbook content):`,
    ``,
    "```",
    config.noteTemplate,
    "```",
    ``,
    `## Current Vault Structure`,
    `\`\`\``,
    vaultStructure,
    `\`\`\``,
    ``,
    `## Vault Placement Rules`,
    `- Explore the vault structure above or with \`ls\`/\`find\` as needed.`,
    `- Place the note in the most semantically appropriate folder:`,
    `  - If it relates to an existing project (e.g. "Rust"), put it under that project folder.`,
    `  - If it's a new topic that could form its own category, create a new folder.`,
    `  - Do NOT place notes in the vault root unless they are top-level meta notes (like vault-wide indexes).`,
    ``,
    `---`,
    ``,
    `## User's Raw Input`,
    userInput,
    ``,
    `## Workflow — Follow These Steps IN ORDER`,
    ``,
    `### Step 1: Validate Understanding`,
    `- Read the user's raw input above carefully.`,
    `- Identify any misconceptions, inaccuracies, or incomplete understanding.`,
    `- If something is wrong or could be clarified: **discuss it with the user.** Gently explain what's accurate and what isn't, then ask if they'd like to revise.`,
    `- If you need clarification before writing the note, ask.`,
    ``,
    `### Step 2: Create the Note (only after Step 1 is resolved)`,
    `- Once understanding is accurate (or the user confirms they're happy), create the file.`,
    `- Write the note in the **user's own words and style**, not an encyclopedia entry.`,
    `  Clean up their rambling into the template's structure — each section should feel like the user wrote it after having a clear "aha" moment.`,
    `- Use \`write\` to create the file at \`${config.vaultPath}/<appropriate-path>/<Topic-Name>.md\`.`,
    `- After writing, mention any existing notes that could be [[wikilink]]ed from this new note.`,
  ].join("\n");
}
