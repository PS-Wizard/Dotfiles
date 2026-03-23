---
name: swiss-design
description: Wiz's personal design language for visual output. ONLY load this skill when explicitly asked — triggers include: "use my design language", "swiss design", "apply my aesthetic", or direct requests to style something visually. Do not load for general coding, UI components, or design tasks unless one of these triggers is present.
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

### 1.3 Monochrome First
The default palette is black and white. Color, when used, is singular and surgical — one accent, deployed rarely, with full intention. The absence of color forces every other variable — form, weight, spacing, texture — to work harder. Monochrome is not a constraint; it is an amplifier.

### 1.4 Information Hierarchy Through Contrast
Scale contrast is extreme. A display headline at 200px next to body copy at 10px. A large photograph next to dense tabular data. The jump between levels of hierarchy is never subtle — it is violent and deliberate. The viewer's eye should have no ambiguity about what to read first.

### 1.5 The Beauty of Density and Void
Compositions intentionally oscillate between dense information zones and vast negative space. A page might have one-third covered in tightly-set 8pt metadata and two-thirds of pure void. Neither extreme is wrong. The tension between them creates visual rhythm.

### 1.6 Data as Image, Image as Data
Data visualization, photography, and type are not separate categories — they are visual materials with equal weight. A bar chart can be compositionally treated like a photograph. A halftone dot pattern can be data and image simultaneously. Photography is treated graphically — cropped aggressively, desaturated, used as texture or structural element.

---

## 2. TYPOGRAPHY

### 2.1 Typeface Selection

**Primary / Display:** Grotesque / Neo-grotesque sans-serifs. The canon:
- Helvetica Neue (all weights)
- Suisse Int'l / Suisse Works
- Aktiv Grotesk
- Founders Grotesk
- ABC Diatype
- Neue Haas Grotesk

**Characteristics of approved typefaces:**
- Rational, geometric, optically balanced
- Strong at both micro (7pt) and macro (400pt) sizes
- Minimal stroke contrast
- Generous x-height
- Clean terminals — no decorative elements

**Forbidden typefaces:**
- Inter, Roboto, Arial, San Francisco (too neutral/UI-coded)
- Any decorative serif except in ironic/editorial context
- Script or handwritten fonts (never)
- Anything that calls attention to its own "personality"

**Mono / Code / ASCII contexts:**
- JetBrains Mono, IBM Plex Mono, Fira Code, Courier
- Used for data tables, coordinates, timestamps, technical annotations
- Mono type adds machine-precision texture — use deliberately

### 2.2 Size Scale
Type sizes jump dramatically. There is no "medium" — only large, small, and the contrast between them.

```
DISPLAY:      120px–600px+  (headline as image, bleeds off canvas)
TITLE:         48px–120px   (section anchors, poster titles)
SUBHEAD:       18px–36px    (labels, category markers)
BODY:          12px–16px    (readable prose, descriptions)
CAPTION:        8px–11px    (metadata, coordinates, credits, fine print)
MICRO:          6px–9px     (tabular data, systematic annotations)
```

The gap between DISPLAY and CAPTION is the point. Never compress it.

### 2.3 Weight Usage
- **Black / Heavy (900):** Display text, logo marks, dominant words
- **Bold (700):** Titles, emphasized labels
- **Regular (400):** Body copy, descriptions
- **Light (300):** Sparse usage — subheadings that need to recede
- **No italics** unless genuinely semantic (publication titles, technical terms)

### 2.4 Case

- **ALL CAPS:** Labels, metadata, category tags, coordinates, short functional text. Never long prose.
- **all lowercase:** Display headlines when intimate/editorial tone is needed. "face to face". "deep". "nothing". Creates tension against all-caps metadata.
- **Title Case:** Avoid except for proper nouns.
- **Sentence case:** Body copy only.

The choice between ALL CAPS and all lowercase is itself an expressive decision. Pick one per composition and commit.

### 2.5 Tracking (Letter-Spacing)
- Display type: `-0.02em` to `-0.04em` (tight, compressed)
- ALL CAPS labels: `+0.1em` to `+0.2em` (opened, formal)
- Body copy: `0` to `+0.01em` (default)
- Micro/caption: `+0.05em` to `+0.1em` (slightly opened for legibility)

### 2.6 Leading (Line-Height)
- Display / oversized: `0.85` to `0.95` (compressed, stacked, monolithic)
- Body: `1.4` to `1.6`
- Dense metadata columns: `1.2` to `1.35`

### 2.7 Typography as Image Technique
- **Bleed:** Let type run off canvas edges — crop letterforms intentionally
- **Scale beyond container:** A word larger than its containing element, creating implicit overflow
- **Type and image overlay:** Large type in front of or behind photography
- **Type as texture:** Repeat a word at tiny scale in a grid to create a halftone-like dot field
- **Stacked display:** Each word of a title on its own line, left-aligned, creating a ragged-right step pattern

---

## 3. COLOR

### 3.1 Base Palette
The primary palette is achromatic. All compositions begin here.

```
ABSOLUTE BLACK:     #000000  — deep backgrounds, maximum contrast moments
NEAR BLACK:         #0A0A0A  — ink blacks, body text on light
OFF WHITE:          #F5F4F0  — paper-tone, warm light backgrounds  
PURE WHITE:         #FFFFFF  — clinical, sterile contexts
LIGHT GRAY:         #E8E6E1  — subtle backgrounds, field dividers
MID GRAY:           #888888  — secondary text, ruled lines
```

### 3.2 Accent Colors
**One accent per composition. Maximum.**

Approved accent colors:
```
SIGNAL RED:     #E63329 / #CC2A1E  — urgency, emphasis, tension
WARM YELLOW:    #F2C94C / #D4A017  — warmth, organic accent, glow effect
ELECTRIC BLUE:  #0047FF            — rare, cold, technical contexts only
```

**Rules:**
- The accent color must appear in at most 1–2 elements in the entire composition
- It is used as a **bar**, a **dot**, a **single word**, a **bounding element** — never as a fill
- Maximum saturation — no tints or softened versions
- Red is the most common accent. Use it like a strike-through, a redaction bar, a surgical cut

### 3.3 Color in Photography
- All photography is converted to **grayscale** or **high-contrast black & white**
- Halftone treatment when applicable — dots, squares, or custom patterns
- Photography should feel printed, not digital — grain, ink, paper

### 3.4 Duotone
When duotone is used: one color is always black or near-black. The second is from the accent palette. Never soft gradients — hard, high-contrast duotone.

---

## 4. LAYOUT & GRID

### 4.1 Grid System
All compositions are built on a **modular grid**. Typical configurations:

**Print / Poster:**
- 12-column grid with consistent gutters
- Columns serve as hard alignment anchors
- Margins: generous (8–12% of total width per side) or deliberately broken for bleed effects

**Web / Screen:**
- 12 or 16-column grid
- Two primary content zones: wide (spanning 8+ columns) and narrow (2–4 columns for metadata)
- A clear left edge — most type aligns to a shared vertical axis

### 4.2 Spatial Zones
A composition is divided into distinct spatial zones with intentional hierarchy:

```
ANCHOR ZONE:     Dominant element (display type, oversized image)
BODY ZONE:       Main readable content, mid-scale type
METADATA ZONE:   Small, dense, systematic — dates, labels, coordinates, credits
VOID ZONE:       Active empty space — never fill it
```

### 4.3 Alignment
- **Left alignment is the default.** Always. Right alignment is used only for specific typographic counterpoint (e.g., a right-aligned date against a left-aligned title).
- Centered alignment is essentially never used. It implies softness, approachability — qualities this system rejects.
- Tabular data aligns on a common baseline grid.

### 4.4 Margins and Padding
Generous. Extreme at times. The composition should breathe. A poster might have a dominant element in the lower-left quarter with the rest void. Do not fill space to fill space.

**Key ratios to consider:**
- Large void : dense content = roughly 2:1 or 3:1
- Dominant element can occupy 60–80% of canvas with no other visual competition

### 4.5 Columns for Text
Body text is set in multiple narrow columns (3–4 column editorial style), not one wide measure. Narrow columns with consistent line count. This creates a **printed page / editorial** feel, not a web-article feel.

```
Optimal column width for body: 45–65 characters per line
For metadata / micro text: can be as narrow as 20–30 characters
```

---

## 5. TEXTURE, PATTERN & SURFACE

### 5.1 Halftone
Halftone is a primary graphic technique — not a filter, but a structural element.

**Dot halftone:**
- Circular dots scaling from large (dense shadow) to small (highlight)
- Used to render photography in a printerly, mechanical way
- Dot size variation creates grayscale values without gray color

**Square / Rectangular halftone:**
- Grid of squares — darker areas = larger squares
- More mechanical, digital, Wim Crouwel / early digital aesthetic
- Creates a "screen" or "matrix" texture

**Implementation principle:** Halftone is used when photography needs to feel like a print artifact, a newspaper, a stamp, a signal. It removes the digital smoothness and adds material texture.

### 5.2 Grain / Noise
A subtle noise layer (3–8% opacity) applied globally gives compositions the texture of analog print — paper grain, film grain, risograph registration artifacts. Not visible at a distance, but felt. Prevents the sterility of pure digital.

### 5.3 Geometric Marks
Simple geometric forms used as graphic accents:
- **Horizontal bar (red or black):** A thick band crossing an image or form — acts as a redaction, a divider, a visual cut
- **Arrows:** Bold, angular directional arrows (not decorative, always purposeful)
- **Diagonal line:** Crossing an object to indicate something — annotation, tension, redaction
- **Simple circle:** Used sparingly, often as dot/node in information systems
- **Right-angle corner marks:** Registration-style markers, aligning to grid intersections

### 5.4 Rules and Lines
- Hairline rules (0.5–1px) divide content zones without adding visual weight
- Rules are horizontal — they establish a baseline grid reference
- Vertical rules are used to separate columns in dense editorial layouts
- No decorative rules — only structural ones

### 5.5 ASCII / Dot Matrix Pattern
In digital and code-adjacent contexts:
- Characters as pixels — build images or shapes from ASCII characters
- Uniform character grids that form textures
- Monospaced type arranged in grids to create raster-like visual fields
- This is a native texture for terminal/code contexts and a deliberate aesthetic choice in print contexts

---

## 6. PHOTOGRAPHY & IMAGE TREATMENT

### 6.1 Core Rule
Photography is always **black and white**. No exceptions. Desaturation removes subjectivity — the image becomes shape, form, and contrast rather than mood through color.

### 6.2 Cropping Philosophy
- **Aggressive cropping is preferred over safe framing**
- Close crops isolating details (eyes, hands, mouth, single feature) create intimacy and abstraction simultaneously
- Images can bleed off all four edges of the canvas — the frame is not a container, it is a cut
- Centering the subject is suspect — asymmetric, offset compositions preferred

### 6.3 Contrast Treatment
- High contrast — lift the blacks, crush the shadows
- Grain added: film-like, not smooth
- Images should feel like they could be lithographic prints, newspaper photos, silkscreens

### 6.4 Image-Type Integration
Images and type are treated as **co-equal elements** — they overlap, intersect, contain each other. Techniques:
- Type over image (high contrast, so type reads)
- Image behind oversized type, visible through the shape of letterforms
- Image positioned adjacent to type creating compositional balance
- Photographic element anchoring one zone; type anchoring another
- A bar of color or geometric mark cutting across the image — asserting structure over the organic

### 6.5 Image Scale
Either very large (full-bleed, dominant) or very small (one element in a field of type). Never a medium-sized photograph sitting awkwardly in a composition. Images earn their size.

---

## 7. INFORMATION ARCHITECTURE

### 7.1 Metadata as Design Element
Small, precise, systematic information is as important as the headline. Coordinates, dates, edition numbers, source citations, catalog numbers — these are set in monospaced or condensed sans-serif at 7–10pt and treated as typographic texture. They anchor the composition in specificity and rigor.

**Common metadata elements:**
```
Dates:           "31 MAY 1859"  /  "30.03—03.07.11"
Coordinates:     "51.5007°N 0.1245°W"  /  "09°01'42"N"
Edition marks:   "STEP N°010"  /  "Publication 069"
Credits:         "Cover Photo // Unknown"
Catalog:         "CURATED ON MMXXIII—"
Labels:          "WHO ARE NORDS?"  /  "YEAR 1096 AD"
```

### 7.2 Hierarchy Pattern
A standard 4-level hierarchy applied to all compositions:

```
LEVEL 1 — ANCHOR:     Single dominant element (display type or image)
LEVEL 2 — TITLE:      Compositional title, large but subordinate to anchor
LEVEL 3 — BODY:       Readable explanation, editorial text, descriptions
LEVEL 4 — METADATA:   Systematic small text — dates, sources, labels, data
```

The jump in size between each level is significant. Level 1 might be 10–20× the size of Level 4.

### 7.3 Data Visualization
Data is not decorated — it is structured.
- **Bar charts:** Aligned to a common baseline, vertical or horizontal, high contrast fill, labels rotated or set at 90° when necessary
- **Data overlaid on imagery:** The chart coexists with photography — data and subject merge to make a point
- **Tables:** Monospaced or tabular-figure fonts. Tight leading. Clear column alignment. No borders — alignment creates implicit structure.
- **Scale markers:** Labeled on the left axis in small, precise type. Every tick mark means something.

---

## 8. COMPOSITION ARCHETYPES

Specific layout patterns that recur and can be applied as starting templates:

### 8.1 THE ANCHOR
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
Title anchors bottom-left. Metadata top-right. Void in between.

### 8.2 THE BLEED TYPE
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

### 8.3 THE EDITORIAL
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

### 8.4 THE GRID SYSTEM (Information design)
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

### 8.5 THE IMAGE-TYPE COLLISION
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
Grayscale image with geometric accent (red bar, diagonal line) intersecting it. Type adjacent or overlapping.

---

## 9. MOTION & INTERACTIVITY (Digital Contexts)

When this design language is applied to interactive/web contexts:

### 9.1 Motion Philosophy
- Motion reveals structure — it does not decorate
- **No easing curves that feel "bouncy" or "springy"** — linear or `ease-out` only
- Duration is short: 150ms–300ms for transitions, 400ms–600ms for reveals
- Stagger is a primary tool: elements entering sequentially on a baseline grid, top-to-bottom or left-to-right

### 9.2 Approved Interactions
- Text that snaps into position (no floating/drifting)
- Horizontal or vertical scrolling that feels mechanical, like advancing a reel
- Hover states that are **binary** — on/off, not gradual
- Cursor changes that reinforce the systematic nature (crosshair in data-dense zones)
- Line/rule drawing animations for structural elements

### 9.3 Forbidden Interactions
- Parallax scrolling (cliché, feels decorative)
- Gradient background animations
- Glowing or blurred hover states
- Any animation that references "organic" or "natural" motion
- Scroll-triggered "pop-in" from below (too common, too soft)

---

## 10. VOICE IN VISUAL LANGUAGE

Text content within this design system also has a character:

- **Concise, declarative, no filler words.** "Social Distance." Not "Learn about social distancing."
- **Fragments over sentences** in display contexts. "Timeless." "Nothing." "Deep."
- **Specificity over vagueness.** "31 May 1859" not "historical date."
- **Technical precision.** Coordinates, catalog numbers, edition marks — specificity signals rigor.
- **Lowercase for intimacy, CAPS for authority.** Know which you're using and why.
- **No marketing language.** No "innovative solutions", no "seamless experiences", no adjectives that mean nothing.

---

## 11. WHAT THIS LANGUAGE IS NOT

Explicit rejections — these elements signal a different (unwanted) aesthetic:

| REJECTED | REASON |
|---|---|
| Gradient backgrounds | Decorative, lacks precision |
| Drop shadows | Simulates depth that shouldn't exist |
| Border radius > 2px | Softness, approachability — wrong tone |
| Icon libraries (Heroicons, FontAwesome) | Too UI-generic |
| Multiple typeface families | Dilutes systematic quality |
| Color palette with 5+ colors | Lacks restraint |
| Centered layouts | Implies softness, symmetry-as-default |
| Decorative illustration | Adds noise, no structure |
| Purple / teal / corporate gradients | Coded as tech-generic |
| Cards with shadows and rounded corners | Consumer-UI, not editorial |
| Glassmorphism | Peak late-2020s, no intellectual content |
| Any "friendly" or "approachable" design language | This system is authoritative, not inviting |

---

## 12. QUICK REFERENCE — DECISION CHECKLIST

When making any visual decision, run through:

1. **Is the type large enough to be a shape, or small enough to be texture?** Avoid the forgettable middle.
2. **Is the grid visible through the alignment?** Every element should betray its grid.
3. **Is the negative space doing work?** Void is not a failure to fill — it is compositional tension.
4. **Is the color system being respected?** One accent maximum. Is it earning its presence?
5. **Is photography treated graphically?** Black & white. High contrast. Cropped with intention.
6. **Is the hierarchy unambiguous?** The Level 1 element should be self-evident immediately.
7. **Is the metadata present?** Dates, labels, coordinates — they ground the composition.
8. **Are the typefaces within the approved grotesque canon?**
9. **Does the composition have a single dominant idea?** Not two or three — one.
10. **Would a Swiss designer from 1965 recognize this as structurally sound?**

---
## 13. STRUCTURAL ANNOTATION & SURFACE

### 13.1 The Default Surface
OFF WHITE #F5F4F0 is the material default for any composition.
Not white. Not gray. The warmth of paper, not the sterility of a screen.
Black (#000000) is reserved for maximum contrast moments — when nothing else should exist.

### 13.2 Structural Annotation
Wherever a zone, section, or panel needs a label, the treatment is always the same:
a hairline rule paired with monospace text.

The rule establishes the boundary. The type names it.
This combination — line + mono label — is the primary way structure is made visible.
It applies to any boundary in any medium: a section break, a panel edge,
a content zone, a data region, a page margin. Same logic everywhere.

Label type: monospace, ALL CAPS, MICRO scale, tracking +0.15em
Rule weight: 0.5px–1px, color #C8C6C1 or #888888

### 13.3 Hairline Rules
Rules are structural, never decorative.
- 0.5px–1px only
- They divide, they separate, they define — not ornament
- Color stays in the gray range — never black for a rule
- Alignment creates implicit containers. Rules make them explicit when necessary.

### 13.4 Monospace as the System Language
Monospace is how the system talks about itself.
Any text that describes, labels, indexes, or annotates structure — as opposed to
communicating content — is set in monospace.

Grotesque = what the composition says.
Monospace = how the composition describes itself.

This is absolute. It applies in any medium.

Font stack: JetBrains Mono → IBM Plex Mono → Courier New
Scale: MICRO or CAPTION (8–11px)
Case: ALL CAPS
Tracking: +0.12em to +0.18em

### 13.5 The Grid Mark Motif
A small cluster of rectangles arranged in a 2×2 or 3×2 grid with consistent gutters.
Some cells filled, some empty. Always asymmetric.

This motif signals machine-precision and systematic thinking.
It reads like a registration mark, a punch card, a sensor array.
Scale and position vary by context — it is a compositional accent, not a fixed element.
The filled cells are weight. The empty cells are void. Same philosophy as the whole system.

### 13.6 The Grid Underneath
Alignment is structure made visible without lines.
Every left edge shares a vertical axis. Every column snaps to a module.
Baselines align across zones.

When gridlines are shown explicitly: 4–8% opacity, #888888.
They should read as graph paper beneath the surface — present, not competing.


---

## REFERENCE VOCABULARY

A shared lexicon for describing and requesting work in this system:

| TERM | MEANING IN THIS SYSTEM |
|---|---|
| **Anchor** | The single dominant compositional element |
| **Bleed** | Element that exits the canvas edge intentionally |
| **Metadata zone** | Dense small-type region with systematic information |
| **Void** | Active negative space — never fill it without reason |
| **Signal red** | The accent color — used like a redaction bar or surgical mark |
| **Grotesque** | The typeface category — rational sans-serif, Swiss-derived |
| **Display** | Type used at 80px+ where it functions as image |
| **Halftone** | Dot or square matrix rendering of photographic image |
| **Redaction bar** | Thick horizontal/diagonal bar crossing an image (usually red or black) |
| **Editorial** | Multi-column, print-magazine-like text layout |
| **Collision** | Deliberate overlap of type and image |
| **Monolith** | A single massive element with nothing competing with it |
| **Tabular** | Data presented in precise column-row alignment |
| **Grain** | Noise texture applied to give analog/print tactility |
| **Canon violation** | Intentional break of the grid for compositional tension |


The overall feel should be like a Müller-Brockmann grid was implemented by someone who also obsesses over animation curves.
