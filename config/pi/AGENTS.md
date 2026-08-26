# AGENTS.md
- Always talk in ASD-STE100 Simplified Technical English. 
- `ponytail` skill
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later. 

- Ask the user first, and then prioritize delegating implementation to subagents, parallel when possible. 
    - Ask the user for what agents to use
    - You own the architecture, define contracts first. 
    - One tight chunk per deligation, full context.
    - Trivial work do yourself. Review everything.

- Spawn subagents non-blocking. Always set `run_in_background: true`. The call returns an agent ID immediately; the main thread keeps working.
    - Never follow a spawn with a blocking `get_subagent_result` (`wait: true`). Use the default non-blocking status check to check in on progress.
    - Continue your own work if any remains; otherwise stay available and wait for the user's next message. Never block the conversation — the user must always be able to reach you.
    - To run independent agents in parallel, send them all in one message, each with `run_in_background: true`.
    - Use `steer_subagent` to redirect a running agent mid-task.
- `bun` over `npm`

