---
name: frontend-scroll-css
disable-model-invocation: true
description: >-
  Chrome-first CSS scroll and focus recipes. Use for scroll-driven animations,
  scroll-state container queries, CSS-only carousel controls, scrollytelling,
  reveal/parallax effects, and reading-flow focus order fixes.
---

# Frontend Scroll CSS

Prefer CSS-native scroll and focus features before adding scroll listeners,
IntersectionObserver, or JS carousel state. This skill is intentionally
Chrome-first and recipe-oriented.

## Scroll-driven animations

Use `animation-timeline`, `scroll()`, `view()`, named timelines, and
`animation-range` for scroll-linked progress, reveal, and scrollytelling.

```css
.readingProgress {
  position: fixed;
  inset: 0 0 auto;
  z-index: 100;
  block-size: 3px;
  transform-origin: left;
  background: var(--color-action-bg);
  animation: reading-progress linear both;
  animation-timeline: scroll(root block);
}

@keyframes reading-progress {
  from { scale: 0 1; }
  to { scale: 1 1; }
}
```

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

```css
.storySection {
  view-timeline-name: --story;
  view-timeline-axis: block;
}

.storyImage {
  animation: story-parallax linear both;
  animation-timeline: --story;
  animation-range: entry 0% exit 100%;
}

@keyframes story-parallax {
  from { transform: translateY(8cqb) scale(1.04); }
  to { transform: translateY(-8cqb) scale(1.04); }
}
```

```css
.horizontalScroller {
  overflow-x: auto;
  scroll-snap-type: inline mandatory;
  scroll-timeline-name: --horizontal-progress;
  scroll-timeline-axis: inline;
}

.horizontalProgress {
  block-size: 2px;
  transform-origin: left;
  background: var(--color-action-bg);
  animation: horizontal-progress linear both;
  animation-timeline: --horizontal-progress;
}

@keyframes horizontal-progress {
  from { scale: 0 1; }
  to { scale: 1 1; }
}
```

Always include a reduced-motion override.

```css
@media (prefers-reduced-motion: reduce) {
  .readingProgress,
  .reveal,
  .storyImage {
    animation: none;
    opacity: 1;
    translate: 0 0;
    transform: none;
  }
}
```

## Scroll-state container queries

Use scroll-state queries for sticky, snapped, and scrollable state styling
without JS.

```css
.siteHeader {
  position: sticky;
  top: 0;
  z-index: 50;
  container-type: scroll-state;
}

.siteHeader__inner {
  padding-block: 1rem;
  background: Canvas;
  transition: padding-block 0.2s, box-shadow 0.2s, background 0.2s;
}

@container scroll-state(stuck: top) {
  .siteHeader__inner {
    padding-block: 0.5rem;
    background: color-mix(in oklab, Canvas 86%, transparent);
    box-shadow: 0 1px 0 color-mix(in oklab, CanvasText 16%, transparent);
    backdrop-filter: blur(12px);
  }
}
```

```css
.rail {
  overflow-x: auto;
  scroll-snap-type: inline mandatory;
  container-type: scroll-state;
}

.snapCard {
  scroll-snap-align: center;
  container-type: scroll-state;
}

.snapCard__inner {
  scale: 0.94;
  opacity: 0.72;
  transition: scale 0.2s, opacity 0.2s;
}

@container scroll-state(snapped: inline) {
  .snapCard__inner {
    scale: 1;
    opacity: 1;
  }
}

.railHint {
  opacity: 0;
  transition: opacity 0.2s;
}

@container scroll-state(scrollable: inline) {
  .railHint {
    opacity: 1;
  }
}
```

## CSS-only carousel

Build carousel UX on native scrolling first: `scroll-snap-type`,
`::scroll-button()`, `::scroll-marker()`, `::scroll-marker-group`, and Anchor
Positioning.

```css
.carousel {
  anchor-name: --carousel;
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: minmax(18rem, 80cqi);
  gap: 1rem;
  overflow-x: auto;
  overscroll-behavior-inline: contain;
  scroll-snap-type: inline mandatory;
  scroll-marker-group: after;
  scrollbar-gutter: stable both-edges;
}

.carousel__item {
  scroll-snap-align: center;
}

.carousel::scroll-button(inline-start),
.carousel::scroll-button(inline-end) {
  position: absolute;
  position-anchor: --carousel;
  align-self: anchor-center;
  inline-size: 2.5rem;
  block-size: 2.5rem;
  border-radius: 999px;
  border: 1px solid color-mix(in oklab, CanvasText 24%, transparent);
  background: Canvas;
  color: CanvasText;
}

.carousel::scroll-button(inline-start) {
  content: "‹";
  inset-inline-start: calc(anchor(left) + 0.5rem);
}

.carousel::scroll-button(inline-end) {
  content: "›";
  inset-inline-end: calc(100% - anchor(right) + 0.5rem);
}

.carousel::scroll-marker-group {
  position: absolute;
  position-anchor: --carousel;
  justify-self: anchor-center;
  inset-block-start: calc(anchor(bottom) + 0.75rem);
  display: flex;
  gap: 0.5rem;
}

.carousel__item::scroll-marker {
  content: "";
  inline-size: 0.5rem;
  block-size: 0.5rem;
  border-radius: 999px;
  background: color-mix(in oklab, CanvasText 28%, transparent);
}

.carousel__item::scroll-marker:target-current {
  background: var(--color-action-bg);
}
```

## Reading flow

Prefer correct DOM order. If a Grid/Flex layout must visually reorder items,
use `reading-flow` and `reading-order` to align focus and reading order.

```css
.dashboardGrid {
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  reading-flow: grid-rows;
}

.dashboardGrid__primaryAction {
  reading-order: -1;
}

.toolbar {
  display: flex;
  flex-direction: row-reverse;
  reading-flow: flex-visual;
}
```

## Do not

- Use scroll listeners for effects CSS timelines can express
- Animate layout-heavy properties during scroll
- Apply large parallax to body text
- Ship scroll animation without `prefers-reduced-motion`
- Build custom carousel focus handling when native scroll controls suffice
