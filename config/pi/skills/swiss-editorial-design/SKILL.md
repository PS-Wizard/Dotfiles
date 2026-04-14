---
name: swiss-editorial-design
description: create art direction, layout systems, wireframes, copy structure, and svelte or tailwind implementations for landing pages, websites, presentations, and slide decks in a swiss editorial style. use when chatgpt must produce work that feels grid-led, typographic, asymmetrical, poster-like, minimal-motion, and informed by classic swiss typography, contemporary editorial web design, and controlled experimental poster systems with optional texture accents.
---

# Swiss Editorial Design

## Objective
Translate briefs into compositions that feel disciplined, editorial, and unmistakably swiss-derived. Treat structure as the main source of expression: grid first, typography second, image or geometry third, texture last.

Before producing substantial output, read these files:
- Read `references/visual-dna.md` for the aesthetic system and mode definitions.
- Read `references/layout-recipes.md` for page, section, and slide composition patterns.
- Read `references/svelte-tailwind.md` when implementation or code is required.
- Read `references/qa-checklist.md` before finalizing.
- Read `references/examples.md` when a concrete pattern or example would help.

## Non-negotiables
- Build on a visible or strongly implied grid.
- Let typography do most of the visual work.
- Use asymmetry with disciplined alignment.
- Create strong scale contrast between display type, body text, and metadata.
- Keep the palette restrained. Prefer one accent color plus neutrals.
- Use whitespace as an active design element, not leftover space.
- Favor editorial tension over friendly product-marketing softness.
- Keep motion minimal and purposeful.
- Treat texture as optional. Use it only when requested or when it clearly strengthens the concept.
- Avoid generic startup UI defaults.

## Required workflow
Follow this order internally even when the user asks directly for code.

1. Define the message hierarchy.
   - Identify the single dominant idea.
   - Rank content into hero, support, metadata, and utility.
   - If the brief is thin, infer a hierarchy and state the inference briefly.

2. Choose the visual mode.
   - Use `classic swiss` for the cleanest and most rigorous interpretation.
   - Use `contemporary editorial` for most web and landing-page work.
   - Use `experimental poster` when the brief can support more tension, distortion, or abstraction.
   - Keep all three modes anchored to the same grid and typographic discipline.

3. Establish the structural system.
   - Choose a desktop-first grid before choosing decorative details.
   - Define margins, gutters, baseline rhythm, and section spacing.
   - Decide where alignment should snap: cap lines, baselines, image edges, numerals, rules, and metadata blocks.

4. Establish the typographic system.
   - Select one primary grotesk or neo-grotesk sans family.
   - Define display, section, body, caption, and label sizes.
   - Decide how dense the leading should feel.

5. Compose the dominant move.
   - Use one major move: oversized type wall, giant numeral, modular geometry, hard image crop, red circle with black line-work, or a strict grid field.
   - Support the move with small precise text blocks and metadata.
   - Do not stack multiple hero ideas.

6. Introduce imagery, shapes, and optional texture.
   - Use geometry and cropping to reinforce the grid.
   - Apply texture only as an accent layer.
   - Protect legibility.

7. Implement with restraint.
   - Use Svelte and Tailwind cleanly.
   - Encode the grid, spacing, and typography as reusable tokens or components.
   - Prefer a few precise classes over decorative accumulation.

8. Apply minimal motion.
   - Use match-and-move, fade, translate, scale, clip, or reveal.
   - Let motion preserve the editorial structure.

9. Run the QA checklist.
   - Verify that the work feels designed by system, not by ornament.
   - Remove anything that weakens the typographic hierarchy or grid clarity.

## Default response pattern
When the user asks for design direction, a layout, or implementation, structure the response in this order unless the user explicitly wants something else:

1. `visual thesis` — one or two sentences defining the concept.
2. `mode` — classic swiss, contemporary editorial, or experimental poster.
3. `grid` — columns, margins, gutters, baseline, and section rhythm.
4. `type system` — fonts, sizes, weights, casing, and density.
5. `palette` — neutrals and accent usage.
6. `composition plan` — how the page or slide is arranged.
7. `implementation notes` — how to build it in Svelte and Tailwind.
8. `motion note` — one short note on transitions if relevant.

If the user asks directly for code, still make choices in this order internally before writing code.

## Core design doctrine

### Treat the grid as the source of confidence
Use a grid that can be felt even when it is not drawn. Every meaningful edge should seem deliberate. Align text blocks, image crops, rules, numerals, buttons, and captions to the same structural logic.

### Treat typography as architecture
Make type carry the composition. Use display text as a field, object, or axis, not just a heading. Use small labels and metadata to create precision and contrast.

### Create asymmetry without chaos
Favor off-center compositions, but keep them controlled. The page should feel balanced by tension, not by symmetry.

### Push scale aggressively
Let one or two elements become very large. Oversized numerals, giant headlines, cropped words, or large geometric forms should anchor the page. Counterbalance them with small exact text.

### Use restraint as a style signal
Do not rely on many colors, many components, or many effects. Limit the palette. Limit motion. Limit corner radii. Limit iconography. The discipline is part of the aesthetic.

### Use editorial rhythm
Think in spreads, posters, and section plates, not generic product blocks. Each section should feel like a designed composition with its own internal hierarchy while still belonging to one system.

## Structural rules

### Grid defaults
Use these defaults unless the brief strongly suggests another choice:
- Desktop canvas width: `1440` to `1728`.
- Outer margins: `48` to `96`.
- Columns: `12` for websites, `6` or `8` for slides, `4` only for simple systems.
- Gutters: `20` to `32`.
- Baseline increment: `8` or `12`.
- Major vertical spacing: multiples of `40`, `60`, `80`, `120`, or `160`.

### Alignment discipline
- Align hero text to the same verticals used by body copy.
- Align microcopy and metadata to real column edges, not approximate positions.
- Snap image crops to the grid whenever possible.
- Let section dividers, rules, and footer elements continue the same rhythm.

### Whitespace discipline
- Leave entire zones empty on purpose.
- Do not fill every gap with supporting text or UI.
- Use empty cells as part of the composition.

### Repetition discipline
- Repeat one structural idea across the page: a grid, a numeral system, a recurring rule, repeated label positions, repeated column spans, or recurring modular shapes.
- Let repetition create identity.

## Typographic rules

### Font selection
Prefer a single sans family with strong weight range.

Use this order of preference:
1. `Suisse Int'l`, `Neue Haas Grotesk`, `Helvetica Now`, or `Univers` if available.
2. `Inter`, `IBM Plex Sans`, `Public Sans`, or `Arial` when using freely available or default-friendly options.
3. Use a second family only when it adds a clearly editorial contrast and does not dilute the system.

### Type character
- Prefer neutral grotesk energy over friendly rounded tech branding.
- Keep display text tight and confident.
- Let body text stay crisp and readable.
- Use lowercase or sentence case most of the time.
- Reserve all caps for labels, coordinates, or metadata.

### Type scale
Use strong jumps, not timid steps.

A good starting scale:
- Overline or micro label: `11` to `13`
- Caption or metadata: `12` to `14`
- Body: `16` to `20`
- Secondary heading: `24` to `40`
- Section heading: `48` to `88`
- Hero display: `96` to `220+`

### Density rules
- Keep display leading tight, often around `0.85` to `0.98`.
- Keep body leading more open, often around `1.3` to `1.5`.
- Use tracking sparingly. Tighten large display type slightly. Add tracking only to small labels or all-caps metadata.

### Text composition
- Break lines intentionally.
- Use short decisive headings.
- Use small information clusters around the hero.
- Introduce section numbers such as `01`, `02`, `03` when they strengthen editorial rhythm.
- Use concise, almost index-like support text rather than long marketing paragraphs.

## Color rules

### Palette logic
Use a restrained palette.
- Base: black, charcoal, off-white, light gray, or paper tones.
- Accent: choose one strong red, orange, or occasionally electric color if the brief supports it.
- Typical structure: `80 to 95 percent` neutrals, `5 to 20 percent` accent.

### Recommended palette starting points
- Black: `#0b0b0b`
- Soft black: `#111111`
- Off-white: `#f3f1ea`
- Light gray: `#e9e7e1`
- Warm gray: `#d9d6cf`
- Signal red: `#e5391f`
- Vermilion orange: `#f05a28`

### Accent behavior
- Use the accent to create hierarchy, not decoration.
- Let the accent highlight the dominant gesture, a rule, a numeral, a CTA, or a shape.
- Do not scatter accent color evenly across the whole page.

## Shape and image rules

### Geometric language
Favor shapes that feel modular and deliberate:
- circles
- semicircles
- rounded rectangles or capsules
- squares and bars
- repeated line systems
- spiral or arc constructions when conceptually useful

Avoid random blobs, soft mesh gradients, and arbitrary organic decoration.

### Image treatment
- Crop aggressively.
- Let images obey the grid.
- Prefer high-contrast photography, monochrome conversion, duotone treatment, or restrained full-color use.
- Let image edges align to columns and rows.
- Use images as blocks, not wallpaper.

### Experimental overlays
When working in `experimental poster` mode, allow one controlled disruption:
- warped line field
- overprinted geometry
- noise veil
- halftone field
- scan or xerox texture
- huge cropped numeral or word

Keep the disruption singular and legible.

## Texture rules
Texture is optional. Default to `off` unless the user asks for it or the concept clearly improves with it.

When using texture:
- Prefer film grain, copier noise, halftone dots, paper tooth, or faint scan artifacts.
- Keep intensity subtle enough to preserve type clarity.
- Apply texture as a layer, not as a replacement for structure.
- Use texture mostly in backgrounds, large image fields, or geometric shapes.
- Do not add texture to every element.

## Interaction and UI rules for websites

### Navigation
- Keep navigation typographic and simple.
- Use left-aligned or edge-aligned nav structures.
- Favor text links, rules, and modest separators over heavy chrome.
- Keep the nav part of the grid, not a detached component bar.

### Buttons and links
- Prefer rectangular or lightly rounded CTAs.
- Avoid soft pill buttons unless the whole system is extremely geometric and restrained.
- Let links feel editorial: underline, arrow, rule, or quiet block treatment.
- Make CTA styling subordinate to the page composition.

### Cards and panels
- Use cards sparingly.
- Favor grid-aligned text groups and ruled compartments over many floating cards.
- If cards are necessary, make them flat, typographic, and structurally aligned.

### Forms and inputs
- Keep fields clean and rectangular.
- Use labels with precise spacing.
- Avoid glossy shadows and ornamental inputs.

## Composition rules for landing pages and websites

### Hero section
The hero must usually contain one dominant move plus two or three small support clusters.

Common successful hero structures:
- giant word or phrase across multiple columns
- giant numeral paired with small metadata blocks
- dominant geometric figure with tightly set type
- hard-cropped image anchored by a rigid grid and captions
- visible poster grid with typographic blocks and one accent field

### Supporting sections
Design every section as a composition, not a template block.

Use patterns such as:
- manifesto statement with small explanatory text
- split editorial image and caption
- feature matrix with rules instead of cards
- case-study spread with giant index number
- quote or claim section with severe scale contrast
- dense metadata or credits section at the end

### Footers
Treat the footer as part of the editorial system.
- Use grid-aligned link groups.
- Use microcopy, credits, addresses, or legal text as a designed block.
- Avoid generic oversized app-footer chrome.

## Composition rules for slide decks
Treat each slide as a poster or spread.

### Slide system
- Use one persistent master grid across the deck.
- Keep footers, page numbers, section numbers, and metadata in stable positions.
- Let each slide make one dominant move only.
- Maintain consistent margins and alignment logic.

### Good slide archetypes
- title slide with giant type and sparse metadata
- section divider with oversized number
- claim slide with one sentence occupying most of the page
- comparison slide built from a strict grid and rules
- image slide with hard crop and caption block
- data or framework slide built from typographic hierarchy, not colorful dashboard styling

### Deck tone
- Speak precisely.
- Use few words per slide.
- Avoid decorative icons and busy infographics unless redrawn in the same system.

## Svelte and Tailwind implementation rules
Read `references/svelte-tailwind.md` before writing code.

High-level rules:
- Encode the grid in reusable utilities or layout primitives.
- Use CSS custom properties for margins, gutters, columns, and typographic sizes.
- Keep a small set of compositional components: grid wrapper, section frame, meta block, rule, hero type, image frame, and texture overlay.
- Prefer semantic HTML and clean Svelte composition.
- Use absolute positioning only when it creates a strong poster move and remains grid-anchored.
- Keep Tailwind class usage precise. Long class lists are acceptable only when they express deliberate layout logic.

## Motion rules
- Default to nearly static pages.
- Use motion to reinforce structure, not to entertain.
- Favor view transitions, match-and-move, slide, reveal, clip, and subtle scale changes.
- Keep durations tight to moderate.
- Avoid bouncy easing, 3D gimmicks, excessive parallax, and decorative scroll choreography.
- Let motion preserve alignment before and after transition.

## Copy direction
- Write concise, exact, editorial copy.
- Prefer nouns, statements, coordinates, labels, captions, and short explanatory paragraphs.
- Avoid inflated startup language, generic inspiration quotes, and casual product-marketing fluff.
- Use metadata as a design asset: dates, version numbers, locations, indexes, credits, issue numbers, and technical notes.

## Anti-patterns
Avoid these failure modes:
- centered startup hero with small heading, paragraph, screenshot, and button row
- too many colors or gradients
- glossy UI chrome, glassmorphism, neumorphism, or soft blur-heavy effects
- random decorative shapes that ignore the grid
- overuse of pill buttons and oversized border radii
- too many cards
- evenly sized sections with no hierarchy
- weak scale contrast
- type that feels playful, bubbly, or cute
- decorative motion that fights the layout
- texture used as a substitute for concept
- cluttered responsive compromises that destroy the desktop composition

## Decision rules for ambiguous briefs
When the brief is vague, default to this recipe:
- choose `contemporary editorial`
- use a `12-column` grid
- use off-white background with black typography and one vermilion accent
- use one grotesk family
- create a hero with one oversized typographic or geometric move
- add small metadata blocks and a section numbering system
- keep motion minimal
- keep texture off unless asked for

## Final QA standard
Before presenting work, verify all of the following:
- The page or slide would still feel strong in grayscale.
- The layout still reads clearly if color is removed.
- The dominant move is obvious within one second.
- Small text feels placed, not sprinkled.
- Empty space feels intentional.
- The composition could plausibly exist as a poster.
- The result does not look like generic SaaS marketing.
- The result feels driven by grid and type, not by decoration.

## Escalation rule
If the user explicitly asks for more experimentation, increase abstraction, scale contrast, cropping severity, and structural tension before adding more colors or more motion.

## Working principle
When in doubt, remove an element, strengthen the grid, enlarge the type, and make the composition more decisive.
