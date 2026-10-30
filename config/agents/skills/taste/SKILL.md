---
name: taste
description: Generic frontend taste for any stack (React, SvelteKit, Astro, plain HTML). Use for any app UI, dashboard, card, chart, landing, or hero to fix bland AI design. No framework code. No npm deps.
---

# Taste

## 1. When to use

Any frontend work: app screen, card, chart, landing, hero, onboarding, settings. If it renders pixels, use this.

## 2. Read first

Read `/home/wizard/Projects/taste/taste.md` before writing code. It is source of truth. This file is only the shortcut.

## 3. Default Quiet. Loud is opt-in only

- **Quiet = default for everything**, incl SaaS landing. White base, off-white cards, much air, real data first, thin dividers. Like Claude Code UI. SaaS landing = Quiet with bigger type, same calm.
- **Loud = opt-in only** for graphic / creative / art-led briefs. One bold move (ASCII face, avatar gang, dotted globe, lime mark, hand line). Never assume it.
- Never mix. One view = one mode. If brief does not say art-led, ship Quiet.

Tokens (only accents allowed, one per view):

```css
:root {
  --white: #FFFFFF;
  --card: #F7F5F0;
  --paper: #EDE6D3;
  --ink: #111111;
  --muted: #6B6B6B;
  --line: #E8E6E1;
  --lime: #D9FF3D;
  --klein: #2140FF;
  --ablue: #4AA8FF;
  --ared: #FF3D1F;
  --agreen: #00C67E;
  --coin: #FFC93D;
  --glow: #FF9A2E;
}
```

Type: heads Funnel Display at 400-500 only, never 700 black. UI small system-ui 12-15px 400-500. Mono for digits. Never Inter or Geist as default.

Quiet order: landing and login = head plus one action, no meta, no fact line. App card = one real context line max or zero, then number/title, rows, one action. Button: height 40-44, padding 10px 20px, 14px/500, radius 999, ink back. Checkboxes: custom 18px, 1.5px ink border, radius 6, ink fill when checked, never native blue.

## 4. Ban check

- No fake eyebrows. Landing, hero, login: zero meta lines. App: one real line max. No `todoblock • calm planning`, no `login • one account`.
- No empty subtext. No stat line under hero like `3 open • 12:31 • 66%`. Delete it.
- No greeting title. Never `Hi`, `Hi again`, `Welcome back`.
- No blue-purple gradient wash. No rainbow. Chart colors muted, never neon.
- No gray box inside gray box. Off-white cards on white, thin `--line` dividers.
- No Inter / Geist default. No 700 black hero. No 3D, no glow, no shader + ASCII + marquee at once.
- No native checkboxes.

## 5. Ship check

1. Quiet by default? If Loud, brief said art-led? If no, revert to Quiet.
2. What is the one move? Name it.
3. What did you delete? Name one junk text you removed.
4. Does it still work in gray? If no, fix contrast first.
5. Would this sit next to Claude UI without shame? If no, simplify.

## 6. Examples (plain HTML + CSS vars only)

Quiet card — one real context line, number at 500, custom boxes:

```html
<div style="background:var(--card);border-radius:24px;padding:22px;max-width:340px;font-family:system-ui,sans-serif">
  <div style="font-size:12px;color:var(--muted)">Tuesday • 12:31</div>
  <div style="font-size:40px;font-weight:500;color:var(--ink);line-height:1;margin:8px 0">1 <span style="font-size:18px;color:var(--muted)">/ 3 done</span></div>
  <label style="display:flex;gap:10px;align-items:center;padding:10px 0;border-top:1px solid var(--line);font-size:15px"><input type="checkbox" checked style="appearance:none;width:18px;height:18px;border:1.5px solid var(--ink);border-radius:6px;background:var(--ink);margin:0"> Draft tokens</label>
  <button style="margin-top:12px;background:var(--ink);color:var(--white);border:0;border-radius:999px;padding:10px 20px;font-size:14px;font-weight:500">Done</button>
</div>
```

Quiet chart — number at 500, bar, no extra fact:

```html
<div style="background:var(--white);border:1px solid var(--line);border-radius:16px;padding:20px;max-width:320px;font-family:system-ui,sans-serif">
  <div style="font-size:36px;font-weight:500;color:var(--ink)">66%</div>
  <div style="display:flex;gap:6px;margin-top:10px">
    <div style="flex:2;height:8px;border-radius:99px;background:var(--ink)"></div>
    <div style="flex:1;height:8px;border-radius:99px;background:var(--line)"></div>
  </div>
</div>
```

Quiet SaaS landing hero — head plus action only, no meta, no fact (Loud needs art-led brief):

```html
<div style="background:var(--white);padding:64px 32px;max-width:640px;font-family:'Funnel Display',system-ui,sans-serif">
  <h1 style="font-size:52px;font-weight:500;line-height:1;letter-spacing:-0.02em;color:var(--ink);margin:0">Tasks, made quiet.</h1>
  <div style="margin-top:20px">
    <button style="background:var(--ink);color:var(--white);border:0;border-radius:999px;padding:10px 20px;font-size:14px;font-weight:500">Start</button>
  </div>
</div>
```

Quiet login — product name, no greeting, no meta:

```html
<div style="background:var(--card);border-radius:24px;padding:22px;max-width:320px;font-family:system-ui,sans-serif">
  <div style="font-size:22px;font-weight:500;color:var(--ink)">Log in</div>
  <input placeholder="admin@admin.com" style="width:100%;margin-top:12px;padding:12px;border:1px solid var(--line);border-radius:12px;font-size:15px">
  <button style="margin-top:12px;background:var(--ink);color:var(--white);border:0;border-radius:999px;padding:10px 20px;font-size:14px;font-weight:500">Log in</button>
</div>
```
