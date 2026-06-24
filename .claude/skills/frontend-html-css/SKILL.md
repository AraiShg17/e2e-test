---
name: frontend-html-css
disable-model-invocation: true
description: >-
  HTML semantics and modern CSS Modules styling (BEM, color-mix, Container Query,
  mobile-first). Use when writing TSX markup, globals.css, or ComponentName.module.css.
---

# Frontend HTML & CSS

Read [reference-css.md](./reference-css.md) for extended patterns.

## HTML (summary)

- One `<main>`, sequential headings, semantic landmarks
- `<button type="button">` vs `<a href>`
- LCP: `fetchpriority="high"` + dimensions; below-fold: `loading="lazy"`
- Overlay: dialog (critical) / popover (light) / details (inline)

## Global CSS tokens

```css
@layer reset, base, theme, components, utilities;

:root {
  color-scheme: light dark;
  interpolate-size: allow-keywords;

  /* raw palette */
  --blue-500: #3b82f6;
  --white: #ffffff;
  --gray-900: #111827;
  --slate-50: #f8fafc;
  --slate-900: #0f172a;

  /* semantic tokens */
  --color-surface: light-dark(var(--white), var(--slate-900));
  --color-text: light-dark(var(--gray-900), var(--slate-50));
  --color-action-bg: var(--blue-500);

  --duration-default: 0.2s;
}
body {
  color: var(--color-text);
  background: var(--color-surface);
  text-autospace: normal;
}
```

Use `env(safe-area-inset-*)` only for edge-attached UI such as full-bleed app
shells, fixed headers/footers, and bottom navigation. Do not add safe-area
padding to the entire `body` by default.

```css
.appShell {
  min-block-size: 100dvb;
  padding-block-start: max(1rem, env(safe-area-inset-top));
  padding-inline: max(1rem, env(safe-area-inset-left))
    max(1rem, env(safe-area-inset-right));
}

.bottomNav {
  position: fixed;
  inset-inline: 0;
  inset-block-end: 0;
  padding-block-end: max(0.75rem, env(safe-area-inset-bottom));
}
```

## Colors

- Prefer variables + 6-digit HEX for design tokens
- Prefer `color-mix(in oklab, var(--x) 80%, transparent)` for transparency; allow `rgb()` / `rgba()` when needed for compatibility or existing code
- Dark mode: `light-dark(var(--light), var(--dark))`
- Browser-generated UI: `color-scheme: light dark`
- High Contrast: `@media (forced-colors: active)` + system colors

## CSS variables

- CSS custom properties must start with `--`, e.g. `--color-action-bg`; read them with `var(--color-action-bg)`
- Use kebab-case and include a category prefix for color, space, radius, duration, etc.
- Use tokens in this order: raw palette → semantic token → component token
- Define raw palette tokens in `:root` to limit the available color set
- Map raw palette tokens into semantic tokens such as `--color-action-bg`
- Define component tokens on the component root and point them at semantic tokens
- Do not use raw palette tokens directly in component properties
- Represent meaningful visual variants, state, and density with explicit props / `data-*`
- Use CSS variables primarily as component-internal tokens
- Use `--_private-token` for internal component implementation
- Only allow external numeric/color overrides through typed `style` when props are not enough
- With CSS Modules, do not target internal classes from caller CSS. Do not make `className` variable injection the default pattern
- Register animatable variables with `@property`

Naming examples:

- Raw palette: `--blue-500`, `--slate-900`
- Semantic color: `--color-surface`, `--color-text`, `--color-action-bg`
- Scale token: `--space-4`, `--radius-md`, `--duration-default`
- Component-private token: `--_card-padding`, `--_card-border`

```css
:root {
  --blue-500: #2563eb;
  --blue-700: #1d4ed8;
  --gray-50: #f9fafb;
  --gray-900: #111827;

  --color-surface: var(--gray-50);
  --color-text: var(--gray-900);
  --color-action-bg: var(--blue-500);
  --color-action-bg-hover: var(--blue-700);
}

.card {
  --_card-density: 1;
  --_card-accent: var(--color-action-bg);
  --_card-padding: calc(1rem * var(--_card-density));

  padding: var(--_card-padding);
  border-color: color-mix(in oklab, var(--_card-accent) 24%, transparent);
}

.card[data-density='compact'] {
  --_card-density: 0.75;
}
```

## Layout pattern

`.container` (stretch) → `.section` → `.sectionInner` (max-width + padding)

## Gap decorations

When a grid, flex, or multicol gap needs a visual divider, prefer `column-rule`
and `row-rule` over borders, background hacks, or pseudo-elements. Good fits:
calendars, pricing tables, settings rows, card grids, and horizontal link lists.
Treat this as Chrome-first progressive enhancement for Chrome / Edge 149+.

```css
.calendarGrid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 0.75rem;
  column-rule: 1px solid var(--color-border);
  row-rule: 1px solid var(--color-border);
  column-rule-break: intersection;
  row-rule-break: intersection;
}
```

```css
.linkList {
  display: flex;
  flex-wrap: wrap;
  column-gap: 0.75rem;
  row-gap: 0.5rem;
  column-rule: 1px solid color-mix(in oklab, var(--color-text) 24%, transparent);
}
```

Use `repeat()` for patterned rules such as calendars, schedules, and sudoku-like
layouts.

```css
.scheduleGrid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 0.5rem;

  row-rule-width: repeat(auto, 2px, 1px);
  row-rule-style: repeat(auto, solid, dashed);
  row-rule-color: var(--color-border-strong), var(--color-border);
}
```

- `rule`: shorthand for `column-rule` and `row-rule`
- `column-rule` / `row-rule`: draw lines inside gaps
- `column-rule-break` / `row-rule-break`: control decoration breaks at intersections
- `rule-break: none`: rules run continuously through intersections
- `rule-break: intersection`: grid intersections are visually adjusted
- `rule-inset`: controls how far rules are inset from gap edges
- `rule-visibility-items: between`: only show rules between adjacent items
- Rule width / color / inset can transition for hover or selected states
- Use `@supports` fallback to border/background hacks when unsupported

## Responsive

- Component layout uses Container Query by default
- Use `@media` for viewport, OS preference, and input-device conditions
- Put `container-type: inline-size` on the component root
- Use `container-name` for complex/nested components
- Prefer `cqi` / `cqb` / `cqmin` / `cqmax` for component-relative sizing

Decision split:

- Component layout changes: `@container`
- Component-local spacing/type/gap: `cqi` / `cqb`
- Viewport, OS preference, input device: `@media`
- Sticky/snapped/scrollable state: `container-type: scroll-state`

`1cqi` is 1% of the container inline size. In horizontal writing modes, this is
effectively 1% of the component width.

```css
.productCard {
  container-type: inline-size;
  container-name: product-card;
  padding: clamp(0.75rem, 4cqi, 1.25rem);
}

@container product-card (width >= 36rem) {
  .productCard__body {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
  }
}
```

```css
.toolbar {
  container-type: inline-size;
  gap: clamp(0.375rem, 2cqi, 1rem);
}

.toolbar__label {
  font-size: clamp(0.875rem, 3cqi, 1rem);
}

@media (pointer: coarse) {
  .toolbar__button {
    min-inline-size: 44px;
    min-block-size: 44px;
  }
}
```

## BEM in CSS Modules

- `.card`, `.card__title`, `.cardHeader`, `.card--featured`
- Nest `:hover`, `@media`, `@container` inside class blocks
- Keep `@keyframes` and `@supports` outside blocks
- Use `@layer` for cascade order, `:where()` for low-specificity defaults, `:has()` for parent state, and `@scope` for proximity-sensitive rules
- Prefer Container Query + `cqi` / `cqb` and `subgrid` for component layouts

## Focus & motion

- `:focus-visible` on all interactive elements
- No hover styles on non-interactive elements
- `prefers-reduced-motion: reduce` fallback required
- `forced-colors: active` fallback required for custom focus and color-heavy UI

## Layout safety (modals)

- `justify-content: safe center`
- `isolation: isolate` on overlay roots
- `overscroll-behavior: contain` on dialog/popover
