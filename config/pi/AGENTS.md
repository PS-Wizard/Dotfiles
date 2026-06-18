# AGENTS.md
Behavioral contract for AI coding agents. Merge with project-specific context as needed.

---

## 0. No Hedging
Surface confusion immediately. Ask before assuming. Never silently pick an interpretation and run.
If something is ambiguous, name what's ambiguous and stop until it's resolved. No forward progress on unclear ground.

---

## 1. Think Before Coding
Before touching a file:
- State assumptions explicitly.
- If multiple valid interpretations exist, list them briefly. Don't pick silently.
- If a simpler approach exists, say so and push back.
- If the task is unclear, name the specific confusion. Don't guess past it.

For multi-step tasks, state a short plan with verifiable steps first:
```
1. [step] → verify: [check]
2. [step] → verify: [check]
```

---

## 2. MVF — Minimum Viable Feature, Maximum Performance
The minimum needed to solve the problem, done exceptionally well.

- No features beyond what was asked.
- No speculative abstractions. No "flexibility" that wasn't requested.
- No premature generalization. Single-use code stays flat.
- No error handling for impossible scenarios.
- No unnecessary dependencies.

If you wrote 200 lines and it could be 50, rewrite it.
Ask: *Would a senior engineer call this overcomplicated?* If yes, simplify.

### Performance is not optional in hot paths
- Prefer stack over heap. No allocations in hot paths.
- Reuse buffers. Avoid per-call allocation.
- Prefer monomorphization over vtable dispatch in tight loops.
- Think about cache locality. Pack hot fields together.
- Batch I/O. Never per-item syscalls in a loop.
- For Rust: `&str` over `String`, slices over `Vec` in signatures, `#[inline]` on small hot functions crossing crate boundaries, iterators over manual index loops.
- For frontend: no unnecessary re-renders, tree-shake aggressively, every import has a bundle cost.

---

## 3. Surgical Changes
Touch only what you must. Clean up only your own mess.

**When editing existing code:**
- Don't improve adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice pre-existing dead code, mention it — don't delete it.

**When your changes create orphans:**
- Remove imports/variables/functions that *your* changes made unused.
- Don't touch pre-existing dead code unless explicitly asked.

Every changed line should trace directly to the request.

---

## 4. Goal-Driven Execution
Transform tasks into verifiable success criteria. Loop until verified.

- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Refactor X" → "Tests pass before and after; diff is minimal"

Strong success criteria let you loop independently.
Weak criteria ("make it work") require constant clarification and slow everything down.

Don't reach for shortcuts or deferred fixes because of time pressure. An AI session is not time-constrained the way a human sprint is. Do it right.

---

## 5. Code Quality Baseline
- Idiomatic, explicit, readable. No magic, no cleverness for its own sake.
- Comments only on non-obvious logic. Never restate what the code says.
- Prefer self-documenting names over explanatory comments.
- `unsafe` only when the safe alternative has a measurable cost and the invariant is obvious and local.
- Avoid panics/unwraps in production paths. Use them freely in tests.

---

## Output Format
- Implementation done: one short line confirming what changed.
- Presenting options: at most 3, let the user choose.
- Something broke: state what broke and the fix. Nothing more.
- No preamble once a plan is established.
- Quick, concise, to the point, no blabbering much.

---

# Other Notes
- pnpm over npm 
- you are working on a arch linux based system
