# CSS Reference (extended)

## Cascade layers, scope, and modern selectors

```css
@layer reset, base, theme, components, utilities;

@layer components {
  @scope (.card) {
    :scope {
      container-type: inline-size;
    }
    .card__title:where(:not(:empty)) {
      text-wrap: balance;
    }
    :scope:has(.card__media) {
      display: grid;
    }
  }
}
```

## Component-first Container Query

```css
.productCard {
  container-type: inline-size;
  container-name: product-card;
  padding: clamp(0.75rem, 4cqi, 1.25rem);
}

.productCard__body {
  display: grid;
  gap: clamp(0.5rem, 2cqi, 1rem);
}

@container product-card (width >= 36rem) {
  .productCard__body {
    grid-template-columns: minmax(0, 1fr) auto;
    align-items: center;
  }
}
```

## Container units and environment media

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

@media (prefers-reduced-motion: reduce) {
  .toolbar__button {
    transition: none;
  }
}
```

## Component CSS variable API

```css
@property --_card-accent-mix {
  syntax: '<percentage>';
  inherits: false;
  initial-value: 0%;
}

.card {
  --_card-density: 1;
  --_card-accent: var(--color-action-bg);
  --_card-padding: calc(1rem * var(--_card-density));
  --_card-border: color-mix(in oklab, var(--_card-accent) var(--_card-accent-mix), transparent);

  padding: var(--_card-padding);
  border: 1px solid var(--_card-border);
  transition: --_card-accent-mix 0.2s;
}
```

## Forced colors and touch targets

```css
@media (forced-colors: active) {
  .button {
    border: 1px solid ButtonText;
    color: ButtonText;
  }
}

@media (pointer: coarse) {
  .button {
    min-inline-size: 44px;
    min-block-size: 44px;
  }
}
```

## Subgrid and container units

```css
.grid {
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
}
.card {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: span 12;
  container-type: inline-size;
}
.cardTitle {
  font-size: clamp(1rem, 4cqi, 1.5rem);
}
```

## Scroll-driven reading progress

```css
.readingProgress {
  position: fixed;
  inset: 0 0 auto;
  block-size: 3px;
  transform-origin: left;
  animation: reading-progress linear both;
  animation-timeline: scroll(root block);
}

@keyframes reading-progress {
  from { scale: 0 1; }
  to { scale: 1 1; }
}
```

## View timeline reveal

```css
.reveal {
  opacity: 0;
  translate: 0 2rem;
  animation: reveal-on-view linear both;
  animation-timeline: view(block);
  animation-range: entry 10% cover 35%;
}

@keyframes reveal-on-view {
  to {
    opacity: 1;
    translate: 0 0;
  }
}
```

## Named scroll timeline

```css
.horizontalScroller {
  overflow-x: auto;
  scroll-timeline-name: --horizontal-progress;
  scroll-timeline-axis: inline;
}

.horizontalProgress {
  transform-origin: left;
  animation: horizontal-progress linear both;
  animation-timeline: --horizontal-progress;
}

@keyframes horizontal-progress {
  from { scale: 0 1; }
  to { scale: 1 1; }
}
```

## Scroll-state sticky header

```css
.siteHeader {
  position: sticky;
  top: 0;
  container-type: scroll-state;
}

@container scroll-state(stuck: top) {
  .siteHeader__inner {
    padding-block: 0.5rem;
    box-shadow: 0 1px 0 color-mix(in oklab, CanvasText 16%, transparent);
  }
}
```

## Reading flow

```css
.dashboardGrid {
  display: grid;
  reading-flow: grid-rows;
}

.dashboardGrid__primaryAction {
  reading-order: -1;
}
```

## @property animation

```css
@property --theme-color {
  syntax: '<color>';
  inherits: true;
  initial-value: #3b82f6;
}
.card {
  transition: --theme-color var(--duration-default);
}
```

## Accordion (::details-content)

```css
.accordion::details-content {
  height: 0;
  opacity: 0;
  overflow: clip;
  transition:
    height var(--duration-default),
    opacity var(--duration-default),
    content-visibility var(--duration-default) allow-discrete;
}
.accordion[open]::details-content {
  height: auto;
  opacity: 1;
}
```

## Dialog animation

```css
.dialog[open] {
  opacity: 1;
  scale: 1;
  transition: opacity 0.3s, scale 0.3s, overlay 0.3s allow-discrete;
}
@starting-style {
  .dialog[open] {
    opacity: 0;
    scale: 0.95;
  }
}
.dialog::backdrop {
  background: color-mix(in oklab, #000 50%, transparent);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}
```

## Style queries (optional)

```css
:root {
  @media (width >= 768px) { --md: true; }
}
.section {
  @container style(--md: true) {
    padding-block: var(--space-16);
  }
}
```

## nth-child(of)

```css
.item:nth-child(2 of .highlight) {
  /* 2nd among .highlight siblings */
}
```

## display multi-value

```css
.grid { display: block grid; }
.flex { display: block flex; }
```

## text-box (optional)

```css
@supports (text-box: trim-both cap alphabetic) {
  .trimmedText {
    text-box: trim-both cap alphabetic;
  }
}
```

References: MDN Web Docs, Chrome Developers, web.dev, and public Web platform
implementation guides.
