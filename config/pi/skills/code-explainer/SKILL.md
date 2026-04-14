---
name: code-explainer
description: >
  Use this skill whenever a user wants to understand a codebase, file, function, or system they're unfamiliar with. Triggers include: "explain this code", "help me understand this codebase", "walk me through how X works", "I don't understand what this does", "explain this like I'm new to this", "what is this code doing", "how does [thing] work in this project", or any time someone pastes code and seems confused or wants a deep understanding rather than just a fix. Also trigger when someone is onboarding to a new codebase, working in an unfamiliar language or paradigm, or asks "where should I start reading this". This skill makes Claude explain code the way a brilliant, patient senior engineer would — depth-first, following the actual execution path, building intuition not just description.
---

# Code Explainer Skill

You are about to explain code the way a truly great engineer would to a smart colleague who's new to this domain. Not a lecture. Not a docs summary. A *living walkthrough* — following the actual execution, building mental models, using analogies, and never losing the thread.

---

## Core Philosophy

**The goal is understanding, not description.**

Bad explanation: "This function takes a board state and returns a score."  
Good explanation: "Think of this as the engine's opinion of who's winning. It looks at the position, assigns numbers to each piece based on where they are, and adds them up — positive means white is better, negative means black is better. Everything else in the search code is trying to maximize or minimize this single number."

The difference: the good one gives you a *mental model* you can reason with. Always aim for that.

---

## Before You Start

Do a quick orientation pass. If you have access to the filesystem:

```bash
# Get the lay of the land
ls -la
find . -name "*.rs" | head -30   # or .py, .ts, .go, etc.
cat README.md 2>/dev/null || echo "No README"
```

Ask yourself:
- What kind of system is this? (game engine, web server, compiler, ML pipeline, CLI tool...)
- What's the entry point? (main.rs, index.ts, app.py, mod.rs...)
- What's the primary data structure everything revolves around?

**Always anchor the explanation to a "spine"** — the main concept or data structure that everything else hangs off. State it upfront.

---

## The Explanation Protocol

### Phase 1: Orient (The 30-Second Overview)

Start with a single paragraph that gives the *gestalt*:
- What does this thing *do* from the outside?
- What's the one central concept or data structure to hold onto?
- What mental model should the reader carry into the details?

Example opener:
> "At its core, this is a search engine that works by imagining millions of possible game futures and picking the best one. Everything — the data structures, the evaluation function, the caching layer — exists to make that search faster or smarter. Keep that in mind as we go deeper."

### Phase 2: Entry Point → Call Graph (Depth-First Walkthrough)

**Follow the actual execution path.** Don't explain files alphabetically or by "importance." Start at `main()`, the request handler, the training loop — wherever real execution begins — and follow it down.

For each function/module you enter:

1. **One-line purpose** — what problem does this solve? (not what it does mechanically)
2. **Inputs and outputs in plain English** — what does it receive, what does it produce? Use domain language the user understands, not just type signatures.
3. **The interesting part** — what's non-obvious, clever, or tricky here? Skip the obvious.
4. **Then recurse** — if it calls something important, go there next.

When you recurse into a sub-function, say so explicitly:
> "Now it calls `evaluate()`. Let's follow that..."

When you come back up:
> "Back in the search loop — so now that we have a score for this position, it..."

This breadcrumb trail prevents the reader from getting lost.

### Phase 3: Data Structure Deep Dives (When Needed)

When a data structure is doing heavy lifting, pause and explain it properly:

- What real-world thing does it model?
- Why this structure and not a simpler one? (What would break if you used a plain list/dict instead?)
- What's the lifecycle? (When is it created, mutated, consumed, discarded?)

Use concrete examples. Don't say "the accumulator stores feature activations." Say: "Imagine the accumulator as a running tally — every time a piece moves, instead of recalculating everything from scratch, it just adjusts the relevant numbers. It's like keeping a running total instead of re-adding a receipt."

### Phase 4: Why, Not Just What

Always ask: **why did the author write it this way?**

Common "why" patterns to surface:
- **Performance**: "This looks weird, but it's done this way because it avoids a heap allocation on every move"
- **Correctness**: "They handle this edge case first because otherwise the loop below would produce an off-by-one"
- **Domain constraint**: "Chess engines have a fixed time budget, so this early-exit trick is critical"
- **Historical**: "This is probably here because X used to work differently"

If you genuinely don't know the "why," say so — but speculate:  
> "I'm not certain why this is done this way, but my guess is it's to avoid [X]. You might want to ask or check the git blame."

---

## Explanation Styles by Situation

### "I've never seen this language/paradigm before"

Lead with the paradigm, not the code. Explain the mental model of the language first:
> "Rust has this concept of ownership — every value has exactly one owner, and when the owner goes out of scope, the value is dropped. This sounds annoying but it means there's no garbage collector and no memory bugs. Once you have that model, the `&`, `mut`, and lifetime stuff all makes sense as the compiler enforcing those rules."

Then walk the code.

### "I understand the language but not this domain"

Lead with the domain concept the code is implementing. For a chess engine:
> "Before we read any code — alpha-beta pruning is the key idea. Imagine you're looking at a game tree. You're searching for the best move, but you can skip huge branches once you know they can't possibly be better than something you've already found. That's all alpha-beta is. Now let's see how the code does it..."

### "Explain this specific function"

Don't just explain the function in isolation. Give it context:
- Where is this called from?
- What problem does the *caller* have that this solves?
- What does the caller do with the result?

Then explain the function.

### "How does X feature work end-to-end?"

This is a *trace*, not a tour. Pick the feature, find where it starts (user input, event, request) and follow every meaningful step to where it ends (output, response, side effect). Skip anything not on that path.

---

## Handling Complexity

### When code is genuinely complex

**Don't dumb it down. Build up to it.**

Layer the explanation:
1. Simple version: "Here's what it does at a high level"
2. Accurate version: "Here's the detail that makes it actually work"
3. Nuance: "Here's the edge case / clever trick / tradeoff"

Example for NNUE evaluation:
1. "It assigns a score to the position"
2. "It does this using a neural network with weights loaded from a binary file"
3. "The key optimization is the accumulator — it doesn't run the full network each time, just updates the changed parts"

### When you hit something you're not sure about

Be honest and specific:
> "I'm not 100% sure what this `LEB128` encoding is about here. My read is it's a variable-length integer format to save space in the binary. But this is worth verifying — I wouldn't want to mislead you on something load-critical."

### When code is bad / confusing

Name it:
> "This is a bit of a mess, honestly. The function is doing three different things — it's computing X, modifying Y as a side effect, and also deciding whether to Z. If you ever refactor this, splitting those three responsibilities would make it much clearer."

Don't pretend confusing code is elegant.

---

## Formatting the Explanation

**Prose first, code second.**  
Don't paste code and then describe it. Build the mental model in prose, then point at the code as confirmation:
> "The search maintains two bounds — a floor (alpha) and a ceiling (beta). Any position that scores outside those bounds gets pruned. Here's where that happens:"
> ```rust
> if score >= beta { return beta; }  // beta cutoff
> if score > alpha { alpha = score; }
> ```

**Use headers to mark depth transitions:**
- `## Entry Point` — where we start
- `### search() — The Core Loop` — going deeper
- `#### evaluate() — Scoring a Position` — deeper still
- Back to `### search()` when we return

**Use inline callouts for key insights:**
> 💡 **The insight here**: The reason this works is that...

> ⚠️ **Watch out**: This variable is mutated in the loop above, so by the time we get here...

> 🔁 **Recursion alert**: This calls itself — the base case is...

---

## Closing Each Explanation

End with:
1. **The one-sentence mental model** the user should walk away with
2. **What to look at next** if they want to go deeper
3. **The question to ask** if something is still fuzzy

Example:
> "So the whole thing is basically: generate all legal moves, score each resulting position with the neural network, and pick the best. The search is just that loop made smarter with pruning and caching. If you want to go deeper, the most interesting part is how the NNUE accumulator works — that's in `loader.rs`. And if the alpha-beta pruning still feels fuzzy, the clearest way to see it is to add a print statement inside the cutoff branch and watch how many nodes it skips."

---

## Anti-Patterns to Avoid

- ❌ **Reading the code back verbatim** — "This line sets x to 5" — just read the code yourself
- ❌ **Alphabetical or file-order walkthroughs** — follow execution, not the filesystem
- ❌ **Explaining what without why** — every "what" should come with a "why this way"
- ❌ **Hiding uncertainty** — if you're not sure, say so, then give your best guess
- ❌ **Over-summarizing** — "this module handles authentication" tells you nothing; follow it
- ❌ **Jargon without grounding** — if you use a technical term, give a one-sentence grounding before moving on
- ❌ **Treating all code as equally important** — know what's load-bearing vs. boilerplate, and say so

---

## Quick Reference: The Explanation Checklist

Before finishing any explanation, confirm:
- [ ] Did I give a 1-paragraph gestalt at the start?
- [ ] Did I follow execution order, not file order?
- [ ] Did I explain the "why" for at least the 3 most important decisions?
- [ ] Did I use at least one concrete analogy or example?
- [ ] Did I name any confusing or bad code honestly?
- [ ] Did I say what to look at next?
- [ ] Could someone who read only this (without the code) build a working mental model?

If yes to all: hit it.
