# Svelte and Tailwind Implementation Notes

Use this file when translating the design language into code.

## Implementation philosophy
Build a system, not a one-off collage. Encode the grid, type scale, spacing rhythm, and palette into reusable primitives so every section feels related.

## Good technical defaults
- Use Svelte components to separate structure from content.
- Use Tailwind for layout speed, but rely on CSS variables for the main design tokens.
- Keep the page desktop-first.
- Optimize for large laptop and desktop widths first.
- If smaller breakpoints are needed later, simplify the composition rather than shrinking every relationship proportionally.

## Useful root tokens
Start from tokens like these and adapt as needed:

```css
:root {
  --page-bg: #f3f1ea;
  --text: #0b0b0b;
  --muted: #5c5c57;
  --accent: #f05a28;

  --page-margin: 56px;
  --grid-cols: 12;
  --gutter: 20px;
  --baseline: 8px;

  --display-1: clamp(7rem, 12vw, 14rem);
  --display-2: clamp(4rem, 7vw, 8rem);
  --section-title: clamp(2.5rem, 4vw, 5rem);
  --body: 1rem;
  --meta: 0.75rem;
}
```

## Useful layout primitives
Create a small set of reusable wrappers.

### Page frame
Use one wrapper that sets margins and width behavior.

### Editorial grid
Use one reusable 12-column grid container.

Example starting point:

```svelte
<div class="mx-[56px] grid grid-cols-12 gap-x-5">
  <slot />
</div>
```

### Section frame
Give each section a predictable vertical rhythm such as `py-20`, `py-28`, or `py-32`, then vary the internal composition rather than the outer system.

### Meta block
Create one component for captions, labels, dates, issue numbers, and side notes. Use it repeatedly.

### Rule
Create one consistent rule style for dividers. Thin borders often work better than shadowed panels.

## Tailwind habits that support the aesthetic
Prefer these patterns:
- `grid grid-cols-12`
- `col-span-*` and `col-start-*` for precise placements
- `tracking-tight`
- tight custom leading values for display text
- subtle borders instead of shadows
- precise arbitrary values when needed for margins, size, or offsets
- `uppercase` only for small labels, not for major paragraphs

Avoid these patterns unless clearly justified:
- heavy shadow stacks
- colorful utility combinations everywhere
- many rounded pills
- decorative blur backdrops
- default card grids with identical spacing and radius

## Suggested component set
Use a component vocabulary like this:
- `GridOverlay.svelte` for optional visible grid lines
- `MetaBlock.svelte` for labels and metadata
- `PosterHero.svelte` for the dominant top section
- `EditorialSection.svelte` for structured content spreads
- `Rule.svelte` for consistent dividers
- `TextureOverlay.svelte` for optional grain or halftone layers

Do not create too many component types. Reuse a small system.

## Hero implementation guidance
A strong hero often needs one of these structures:
- giant headline spanning 8 to 10 columns with a small descriptor in 2 to 3 columns
- large numeral anchored to one side and layered with other content
- modular shape block occupying 5 to 7 columns next to typographic content
- hard-cropped image with captions aligned to a margin rail

Use absolute positioning only when the element still clearly belongs to the grid.

## View transition guidance
The user prefers match-and-move transitions.

Use motion like this:
- preserve the same structural anchors across states
- transition position and size of major blocks
- fade or clip smaller supporting items
- keep durations around `250ms` to `700ms`
- use calm easing

Avoid:
- bounce
- springy overshoot
- decorative stagger on every small element
- large parallax effects

## Texture implementation guidance
If texture is requested, keep it lightweight.

Examples:
- subtle background noise using a pseudo-element
- grain overlay with low opacity
- halftone mask on a single large shape or image

Keep texture on a separate layer so it can be toggled off.

## Code quality guidance
- Keep markup semantic.
- Keep content easy to swap.
- Avoid hard-coding every spatial value in each section.
- Promote repeated values into CSS variables or shared classes.
- Let implementation clarity match the visual clarity.
