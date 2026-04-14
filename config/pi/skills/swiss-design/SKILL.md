---
name: swiss-design
description: >-
  Wiz's personal design language for visual output. ONLY load this skill when
  explicitly asked — triggers include: "use my design language", "swiss
  design", "apply my aesthetic", or direct requests to style something
  visually. Do not load for general coding, UI components, or design tasks
  unless one of these triggers is present.
license: MIT
compatibility: opencode
---

## 0. NORTH STAR

This design language lives at the intersection of **Swiss International Typographic Style**, **editorial brutalism**, and **systematic minimalism**. Every visual decision is deliberate, rational, and structural. Design is not decoration — it is information made spatial. The grid is law. Type is image. Negative space is active, not empty. Color is used like a scalpel, not a paintbrush.

If a single sentence had to name this aesthetic:

> **"Radical clarity through systematic tension."**

---

## 1. PHILOSOPHY

### 1.1 Type IS the Design
Typography is never supplementary. In most compositions, type is the primary visual element — scaled to architectural proportions, cropped by edges, overlapping images, bleeding off canvas. A single word set at 400px is a shape, a texture, a statement. Text is not placed on top of a layout — it IS the layout.

### 1.2 Grid as Structure, Violation as Expression
Every composition is built on an invisible but rigorous grid — columns, gutters, baselines, modules. However, the most powerful moments come from deliberate, calculated violations of that grid. An oversized letterform that ignores column boundaries. An image that bleeds past the margin. A single element that breaks the system to create tension. The grid must be understood before it can be broken.

### 1.3 Monochrome First (The Two Polarities)
The default palette is strictly monochromatic.
- **The Light Surface:** Ink on paper. `#0A0A0A` on `#F5F4F0`. Creates an editorial, archival, printed artifact feel.
- **The Dark Surface:** The terminal, the monitor, the machine. `#F5F4F0` on `#000000`. Creates a glowing, high-tech, deeply immersive void.
Color, when used, is singular and surgical — one accent, deployed rarely, with full intention. Monochrome is not a constraint; it is an amplifier.

### 1.4 Information Hierarchy Through Contrast
Scale contrast is extreme. A display headline at 200px next to body copy at 10px. A large photograph next to dense tabular data. The jump between levels of hierarchy is never subtle — it is violent and deliberate.

### 1.5 The Beauty of Density and Void
Compositions intentionally oscillate between dense information zones (like a multiplexer terminal or a dense code block) and vast negative space. A page might have one-third covered in tightly-set 8pt metadata and two-thirds of pure void. The tension between them creates visual rhythm.

### 1.6 Data as Image, Image as Data
Data visualization, photography, and type are not separate categories — they are visual materials with equal weight. A bar chart can be compositionally treated like a photograph. A halftone dot pattern can be data and image simultaneously. 

---

## 2. TYPOGRAPHY

### 2.1 Typeface Selection

**Primary / Display:** Grotesque / Neo-grotesque sans-serifs. The canon:
- Helvetica Neue (all weights)
- Suisse Int'l / Suisse Works
- Aktiv Grotesk
- Founders Grotesk
- ABC Diatype

**Mono / Code / System Contexts:**
- JetBrains Mono, IBM Plex Mono, Fira Code.
- Used heavily for data tables, coordinates, timestamps, UI annotations, and terminal-inspired layouts.
- Mono type adds machine-precision texture — use it to contrast the grotesque display type.

**Forbidden typefaces:**
- Inter, Roboto, Arial, San Francisco (too neutral/UI-coded)
- Any decorative serif except in ironic/editorial context

### 2.2 Size Scale & Fluidity
Type sizes jump dramatically. There is no "medium." In responsive contexts, scale type using viewport units (`vw`, `vh`) tied to a `clamp()`, ensuring the *ratio* of contrast never degrades.

```
DISPLAY:      120px–600px+  (headline as image, bleeds off canvas)
TITLE:         48px–120px   (section anchors, poster titles)
SUBHEAD:       18px–36px    (labels, category markers)
BODY:          12px–16px    (readable prose, descriptions)
CAPTION:        8px–11px    (metadata, coordinates, credits, fine print)
MICRO:          6px–9px     (tabular data, systematic annotations)
```

### 2.3 Weight & Case Logic
- **Display:** Black (900) for monolithic presence, or Ultra-Light (100) for delicate, razor-thin structural framing.
- **ALL CAPS:** Labels, metadata, category tags, coordinates. Never long prose. Opened tracking (`+0.1em`).
- **all lowercase:** Display headlines when intimate/editorial tone is needed. Compressed tracking (`-0.03em`).

---

## 3. COLOR

### 3.1 Base Palette
```
ABSOLUTE BLACK:     #000000  — deep backgrounds, maximum contrast moments
NEAR BLACK:         #0A0A0A  — ink blacks, body text on light
OFF WHITE:          #F5F4F0  — paper-tone, warm light backgrounds  
PURE WHITE:         #FFFFFF  — clinical, sterile contexts
MID GRAY:           #888888  — secondary text, structural rules
```

### 3.2 Accent Palette (Maximum one per view)
```
SIGNAL RED:     #E63329 / #CC2A1E  — urgency, redaction, surgical cut
WARM YELLOW:    #F2C94C / #D4A017  — warmth, archival accent
PHOSPHOR GREEN: #00FF41            — terminal environments, raw data only
ELECTRIC BLUE:  #0047FF            — technical, cold diagrams
```
**Rules:** The accent color must appear in at most 1–2 elements. It is used as a bar, a dot, a single word, or a bounding element — never as a generic background fill.

---

## 4. LAYOUT, GRID & RESPONSIVENESS

### 4.1 The Two Doctrines of Viewport Logic
You must determine if a layout is an **Interface** or an **Artifact**.

**Doctrine 1: The Artifact (Anti-Responsive)**
For pure editorial, posters, or digital art pieces. The canvas is fixed. The aspect ratio is sacred. 
- Do **not** reflow content. Do **not** stack columns on mobile.
- Use CSS `transform: scale()` tied to the viewport width, or CSS `aspect-ratio` containers. The user pans and zooms, or the entire canvas scales down proportionally like an image. The grid is never compromised.

**Doctrine 2: The Interface (Fluid Matrix)**
For functional data, articles, and interactive surfaces. The layout adapts, but the brutalist proportions remain.
- Desktop: 12 or 16-column grid.
- Tablet: 8-column grid.
- Mobile: 4-column grid.
- **Critical Rule:** When columns collapse, *hierarchy must not flatten*. If Display text was 15x larger than Body on desktop, it must remain 15x larger on mobile, even if it forces horizontal scrolling or aggressive hyphenation.

### 4.2 Spatial Zones & Alignment
- **Left alignment is the default.** Always.
- A clear left edge — most type aligns to a shared vertical axis. 
- **The Void Zone:** Active empty space. Do not center elements just because there is empty space on the right. Leave it empty.

---

## 5. COMPOSITION ARCHETYPES (THE VARIETY INJECTORS)

To avoid repetitive generation, utilize these distinct structural patterns:

### 5.1 THE ANCHOR (Standard Editorial)
```
┌─────────────────────────────────┐
│                    METADATA     │
│                    DATE / LABEL │
│                                 │
│                                 │
│   DISPLAY HEADLINE              │
│   (large, left-bottom)          │
│                    ┌──────────┐ │
│                    │ METADATA │ │
└─────────────────────────────────┘
```
Title anchors bottom-left. Metadata top-right. Massive void in between. Standard print-poster translated to screen.

### 5.2 THE CASCADING MONOLITH
```
┌─────────────────────────────────┐
│ DISPLAY                         │
│    TYPE                         │
│       BREAKING                  │
│          DOWN                   │
│             THE PAGE            │
│ ─────────────────────────────── │
│  col 1  │  col 2  │  col 3      │
└─────────────────────────────────┘
```
Massive typography steps down the grid diagonally. It dominates the top 80% of the viewport. The bottom 20% contains intensely packed, multi-column micro-text. The contrast is visceral.

### 5.3 THE ARCHIVE / INDEX
```
┌─────────────────────────────────┐
│ TITLE ───────────── INDEX 01.   │
│                                 │
│ [ IMG ]  01_Item_Description    │
│ [ IMG ]  02_Item_Description    │
│ [ IMG ]  03_Item_Description    │
│ [ IMG ]  04_Item_Description    │
└─────────────────────────────────┘
```
Pure utilitarian list formatting. Repeating modules locked to a harsh horizontal baseline grid. Images are treated as thumbnails (strictly squared or landscape, black and white). 

### 5.4 THE ASYMMETRIC SPLIT
```
┌────────────────┬────────────────┐
│                │ 12px body copy │
│                │ set extremely  │
│   MASSIVE      │ tight in a     │
│   VOID OR      │ single, narrow │
│   IMAGE        │ column against │
│                │ the right edge.│
│                │                │
└────────────────┴────────────────┘
```
A brutal 70/30 or 80/20 vertical split. Left side is entirely void, or a single massive, high-contrast greyscale image. Right side is dense, tightly leaded text. 

### 5.5 THE BLEED TYPE
```
┌─────────────────────────────────┐
│DISPLAY TYP                      │
│E THAT BLE                       │
│EDS OFF                          │
│                                 │
│  body copy       body copy      │
│  in columns      in columns     │
│                                 │
└─────────────────────────────────┘
```
Oversized type that exits the canvas. Readable content below in columns.

### 5.6 THE EDITORIAL
```
┌─────────────────────────────────┐
│ LABEL   │   LABEL   │   LABEL   │
│ body    │   body    │   body    │
│ text    │   text    │   text    │
│ column  │   column  │   column  │
│         │           │           │
│ ┌─────────────────────────────┐ │
│ │ DISPLAY ELEMENT (type/img)  │ │
│ └─────────────────────────────┘ │
│ BOTTOM ANCHOR — LARGE TYPE      │
└─────────────────────────────────┘
```
Columnar body text above, dominant display element below or overlapping.

### 5.7 THE GRID SYSTEM (Information design)
```
┌─────────────────────────────────┐
│ 01  02  03  04  05  06  07  08  │
│ ──  ──  ──  ──  ──  ──  ──  ──  │
│ item item item item item item   │
│ item item item item item item   │
│                                 │
│            DISPLAY              │
│                                 │
└─────────────────────────────────┘
```
Numbered grid of items (lists, indexes) with a dominant word or image below.

### 5.8 THE IMAGE-TYPE COLLISION
```
┌─────────────────────────────────┐
│                                 │
│      ┌──────────┐               │
│      │          │  TYPE         │
│      │  IMAGE   │  HERE         │
│      │    ──────┼───────        │
│      │    RED   │               │
│      │    BAR   │               │
│      └──────────┘               │
│                    DESCRIPTOR   │
│                    DESCRIPTOR   │
└─────────────────────────────────┘
```
---

## 6. TEXTURE & SURFACE

### 6.1 Structural Annotation (The Mono-Label)
Wherever a zone, section, or panel needs a label, the treatment is always the same: a hairline rule paired with monospace text.
- Label type: monospace, ALL CAPS, MICRO scale, tracking `+0.15em`
- Rule weight: 0.5px–1px, color `#C8C6C1` or `#333333`

### 6.2 Halftone & Grain
- **Photography:** Always converted to high-contrast black & white. Use CSS filters (`grayscale(100%) contrast(120%)`) or SVG halftone filters.
- **Grain:** A subtle noise layer (3–8% opacity) applied globally via a base64 SVG or CSS mix-blend-mode. Prevents the sterility of pure digital rendering.

### 6.3 ASCII / Grid Motif
A small cluster of rectangles arranged in a 2×2 or 3×2 grid. This motif signals machine-precision and systematic thinking. Reads like a registration mark.

---

## 7. MOTION & INTERACTIVITY (DIGITAL CONTEXTS)
Motion must look like a machine executing a script, not a bouncy UI element. 

### 7.1 The Easing Law
- **Motion is weight and friction.** It is the luxurious counterpoint to the brutalist grid. No bouncy, springy, or lightweight animations. Motion must feel deliberate, suspenseful, and expensive.
- **Primary UI transition curve:** `cubic-bezier(0.76, 0, 0.24, 1)` or `cubic-bezier(0.85, 0, 0.15, 1)`. (A heavy, suspenseful draw, a fluid glide, and a buttery, infinite settle).
- **Duration & Timing:** To achieve luxury, let the motion breathe. Structural reveals should take longer (600ms–900ms). The user should feel the tension of the anticipation before the content smoothly glides into its exact place on the grid.
- **Continuous Feeds:** Linear motion remains acceptable *only* for raw, continuous data feeds (marquees, terminal outputs), where the machine logic overrides the editorial pacing.

### 7.2 Approved Interactions
- **Stagger:** Elements entering sequentially on a baseline grid, top-to-bottom or left-to-right, separated by exactly 50ms delays.
- **Line Drawing:** Hairline rules animating their `width / height` from 0 to 100% to frame content before text appears.
- **FLIP**: FLIP based animation technique, where elements match & move.
