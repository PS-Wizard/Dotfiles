---
description: Execute one or more prompt files from ./prompts/. Reads frontmatter to determine which agent to use and whether to run in parallel or sequentially. Use after /craft has written the prompt files.
agent: build
subtask: true
---

<task>
$ARGUMENTS
</task>

<instructions>
You are executing prompt files from `./prompts/`. The arguments above specify which prompts to run (by number, name, or "last").

## Step 1 — Resolve the files

Parse $ARGUMENTS to extract prompt identifiers (numbers or partial names).

- Empty or "last" → `ls -t ./prompts/*.md | head -1`
- Number like "5" or "005" → find file matching `005-*.md`
- Partial name like "auth" → find file containing "auth" in the name
- Multiple identifiers → resolve each

If a file isn't found, list available prompts and stop.

## Step 2 — Read frontmatter from each resolved file

For each prompt file, extract:
- `agent` — which agent executes it
- `parallelizable` — technical fact, can it run concurrently
- `parallelize` — user's decision, should it run concurrently
- `depends_on` — list of prompt numbers that must complete first, or none

## Step 3 — Determine execution strategy

**If single prompt:** skip to Step 4.

**If multiple prompts:**
- Check `depends_on` chains. Any prompt with `depends_on` must wait for those to finish first.
- Check `parallelize` field. If `parallelize: true` on a group of prompts with no `depends_on` conflicts — run that group in parallel.
- Build the execution order: groups that can run together, sequential steps between groups.

Example:
```
005 (no depends_on, parallelize: true)
006 (no depends_on, parallelize: true)
007 (depends_on: [005, 006], parallelize: false)

→ Run 005 + 006 in parallel, then 007 after both finish
```

## Step 4 — Agent routing

Map the `agent` field to the correct agent name:
- `frontend-craftsman` → frontend-craftsman subagent
- `architect` → architect subagent
- `build` → build (or general-purpose if spawning as subagent)
- anything else → general-purpose

## Step 5 — Execute

**Single prompt or sequential group:**
Read the full prompt file content, then spawn a Task for it with the correct subagent. Wait for completion before moving to the next.

**Parallel group:**
Read all prompt files in the group first, then spawn ALL Task tool calls in a SINGLE message. This is what actually triggers parallel execution. Do not spawn them one at a time.

```
// Correct — parallel:
Task(agent: frontend-craftsman, prompt: [contents of 005])
Task(agent: build, prompt: [contents of 006])
// Both in the same response

// Wrong — sequential despite intent:
Task(agent: frontend-craftsman, prompt: [contents of 005])
// wait...
Task(agent: build, prompt: [contents of 006])
```

Pass the full prompt file content as the task description, not just the filename.

## Step 6 — Archive completed prompts

After each prompt completes successfully, move it:
```
mv ./prompts/NNN-name.md ./prompts/completed/NNN-name.md
```

Create `./prompts/completed/` if it doesn't exist.

If a prompt fails, do NOT archive it. Leave it in place so it can be retried.

## Step 7 — Output summary

```
✓ 005-backend-api.md       build                 parallel group 1
✓ 006-landing-page.md      frontend-craftsman    parallel group 1
✓ 007-integrate-api.md     build                 sequential (after group 1)

All archived to ./prompts/completed/
```

If anything failed:
```
✓ 005-backend-api.md       build                 done
✗ 006-landing-page.md      frontend-craftsman    FAILED — left in ./prompts/
✓ 007-integrate-api.md     build                 done

1 prompt failed. Review ./prompts/006-landing-page.md and retry with /run-prompt 006
```

## Critical rules

- For parallel execution: ALL Task calls for a group MUST be in a single message
- For sequential execution: wait for each Task to fully complete before starting the next
- Never archive a failed prompt
- Always pass full prompt file contents to the Task, not just the path
- If `depends_on` references a prompt that hasn't been completed yet (still in `./prompts/`, not in `./prompts/completed/`), stop and warn the user before proceeding
</instructions>
