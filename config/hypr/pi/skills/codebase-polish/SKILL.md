---
name: codebase-polish
description: >
  Full codebase audit and cleanup pass. Trigger when the user wants to clean up,
  refactor, polish, simplify, or improve the health of an existing codebase.
  Covers: dead code removal, file decomposition, naming, structure, performance
  antipatterns, and modularity. Goal: lean, clean, elegant, and fast — no bloat,
  no god files, no unnecessary abstraction, no noise.
---

# Codebase Polish

**Audit first. Propose before touching. Execute surgically.**

The goal is a codebase that is:
- **Lean** — no dead code, no speculative abstractions, no orphaned files
- **Modular** — each file has one clear responsibility
- **Readable** — names are obvious, logic is flat, no magic
- **Fast** — no performance antipatterns left unaddressed
- **Polished** — the kind of codebase a senior engineer opens and respects immediately

---

## Phase 0 — Audit

Before touching anything, map the patient.

```
1. List all files with line counts. Flag anything over the threshold (see below).
2. For each large file: identify what responsibilities it has. One? Fine. Multiple? Flag it.
3. Find dead code: unused exports, unreachable functions, commented-out blocks, stale TODO/FIXME.
4. Find duplicate logic: same computation in multiple places with no shared abstraction.
5. Find performance antipatterns: per-item allocations, repeated work in loops, unnecessary clones, etc.
6. Find naming inconsistencies: mixed conventions, unclear names, misleading names.
```

Output a prioritized hit list before touching a single file:
```
HIGH  src/utils.ts          (642 lines, 11 responsibilities — decompose)
HIGH  src/api/handler.rs    (dead code: 3 unused fns, 1 commented block)
MED   src/search.rs         (clone in hot loop, L88)
MED   src/components/Card.svelte  (duplicate filter logic also in Table.svelte)
LOW   src/types.ts          (naming: `data`, `info`, `stuff` — rename)
```

Do not proceed to Phase 1 until the audit is reviewed and approved.

---

## Phase 2 — Execute

Work top-down from the hit list. For each item:

### God Files / Large Files
Threshold: **>300 lines** is a yellow flag. **>500 lines** is a red flag — almost always doing too much.

Split by responsibility, not by size. Ask:
- What are the distinct concerns in this file?
- Can each concern be understood in isolation?
- Can I name each piece with a single noun or verb phrase?

Good splits:
```
auth.ts (800 lines) →
  auth/session.ts     — session lifecycle
  auth/tokens.ts      — JWT encode/decode
  auth/middleware.ts  — request guards
  auth/index.ts       — re-exports public API
```

Bad splits:
```
auth.ts (800 lines) →
  auth1.ts
  auth2.ts
```
Size is not a reason to split. Responsibility is.

### Dead Code
- Unused exports: delete them. Don't comment them out.
- Unreachable branches: delete them.
- Commented-out code blocks: delete them. That's what git is for.
- Stale TODO/FIXME older than the current feature: flag, don't delete — ask.

### Duplicate Logic
- Extract to a shared module only if the logic is genuinely identical in intent, not just shape.
- If two pieces look the same but serve different purposes, leave them separate.
- Wrong: DRY for its own sake. Right: DRY because it's the same thing.

### Performance Antipatterns
Common ones to hunt:

**Universal:**
- Repeated computation inside a loop that could be hoisted
- Allocations inside hot paths (collect, clone, format!, vec![])
- String building via concatenation in a loop — use a buffer
- N+1 patterns (loop of queries / loop of fetches)

**Rust:**
- `.clone()` where a reference suffices
- `Box<dyn Trait>` in tight loops — consider enum dispatch
- `.to_string()` / `.to_owned()` on every call — pass `&str`
- Unnecessary `collect()` when an iterator suffices
- Missing `#[inline]` on small hot functions crossing crate boundaries

**Frontend (JS/TS/Svelte):**
- Derived values recomputed on every render — memoize or use `$derived`
- Imports pulling entire libraries for one function
- Reactive statements triggering on unrelated state changes
- Event listeners attached without cleanup

### Naming
A name is good when you can understand it without reading the body.

Bad → Good:
- `data` → what is the data? `userSessions`, `searchResults`, `priceMap`
- `handleStuff` → `flushExpiredTokens`
- `flag` → `isAuthenticated`
- `tmp`, `temp` → either give it a real name or inline it
- `utils.ts` → where possible, split into named modules. If it must exist, at least every export in it should have a precise name.

Consistency rules:
- Pick one convention per language and hold it (camelCase, snake_case, PascalCase where appropriate)
- Boolean names: `is*`, `has*`, `should*`, `can*`
- Collections: plural (`users`, not `userList`, not `userArray`)

### Structure / Modularity
Good module structure has a shape you can explain in one sentence per directory.

```
src/
  api/        — HTTP handlers, request/response types
  db/         — queries, migrations, connection pool
  domain/     — core business logic, no I/O
  services/   — orchestration, calls domain + db + external APIs
  utils/      — truly generic, stateless helpers (keep small)
```

If a file imports from everywhere (domain imports db imports services imports domain) — that's a cycle. Flag it, untangle it.

Barrel files (`index.ts`) are fine for re-exporting a module's public surface. Bad when they become the module itself.

---

## Constraints

- **Never break the public API** of a module without flagging it explicitly.
- **Never delete anything you're unsure about** — flag it, ask.
- **Never rename across the codebase silently** — surface the rename list first.
- **Tests must pass before and after** each phase. If there are no tests, note it.
- **Match existing style** within a file unless the whole file is being rewritten.
- **One concern per PR/commit** — don't bundle decomposition with performance fixes with renames. Separate passes are reviewable passes.
- **ALL BEHAVIOUR AND FUNCTIONALITY MUST REMAIN THE EXACT SAME** -- the refactor SHOULD NOT change any functionality or behaviour.

---

## Output Format

**Audit report:** table format, priority-sorted, one line per finding.
**Before touching a file:** one-line intent (`splitting auth.ts into 3 modules — session, tokens, middleware`).
**After each file:** one-line confirmation (`done — auth.ts deleted, 3 new files, all imports updated`).
**Blockers:** surface immediately, don't work around them.
**Nothing else.**
