---
name: frontend-native-ui
disable-model-invocation: true
description: >-
  Implements overlays with Popover API, Invoker Commands, dialog element, View
  Transitions, and Anchor Positioning. Use for modals, menus, tooltips, drawers,
  page transitions, or floating panels.
---

# Frontend Native UI APIs

## Choose the API

| Need | Use |
|------|-----|
| Must block background, trap focus | `<dialog>` + `showModal()` or `command="show-modal"` |
| Menu, tooltip, toast | `[popover]` + Invoker Commands |
| Inline FAQ | `<details>` / `<summary>` |
| SPA page continuity | View Transitions API |
| Position near trigger | Anchor Positioning |

## Invoker Commands (preferred)

Check target browser support before relying on Invoker Commands. If support is
insufficient, use a polyfill or fall back to `showModal()`, `showPopover()`, and
event handlers.

```html
<button commandfor="panel" command="toggle-popover">Open</button>
<div id="panel" popover="auto">…</div>

<button commandfor="confirm" command="show-modal">Delete</button>
<dialog id="confirm">…
  <button commandfor="confirm" command="close">Cancel</button>
</dialog>
```

## Polyfills (load only if missing)

```javascript
if (!('commandForElement' in HTMLButtonElement.prototype)) {
  await import('invokers-polyfill');
}
if (!('popover' in HTMLElement.prototype)) {
  const { apply } = await import('@oddbird/popover-polyfill/fn');
  apply();
}
```

```css
[popover]:is(:popover-open, .\:popover-open) {
  display: block;
}
```

## React dialog pattern

```tsx
const ref = useRef<HTMLDialogElement>(null);
<button type="button" onClick={() => ref.current?.showModal()}>Open</button>
<dialog ref={ref} className={styles.dialog}>
  <form method="dialog">
    <button value="cancel">Cancel</button>
    <button value="ok">OK</button>
  </form>
</dialog>
```

## CSS requirements

- `isolation: isolate` on overlay root
- `overscroll-behavior: contain` on dialog and `::backdrop`
- `safe center` for flex centering inside scrollable modals
- `@starting-style` for enter animations
- Honor `prefers-reduced-motion`

## View Transitions

```css
@view-transition {
  navigation: auto;
}

.cardImage,
.detailHero {
  view-transition-name: selected-image;
}

@media (prefers-reduced-motion: reduce) {
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none;
  }
}
```

- Use `@view-transition { navigation: auto; }` for same-origin document navigation
- Use `document.startViewTransition(() => updateDOM())` for same-document SPA updates
- Use the same `view-transition-name` on the matching old/new elements for shared element transitions
- Do not duplicate one `view-transition-name` across multiple simultaneously rendered elements
- Stop `::view-transition-old/new(*)` animation for `prefers-reduced-motion`
- In Next.js App Router, do not mix `next/link` with `next-view-transitions` `Link` when route transitions are enabled. Wrap the chosen Link once and use that for internal links

```tsx
import { Link as ViewTransitionLink } from 'next-view-transitions';
import type { ComponentProps } from 'react';

export function AppLink(props: ComponentProps<typeof ViewTransitionLink>) {
  return <ViewTransitionLink {...props} />;
}
```

## Anchor + popover

```tsx
<button style={{ anchorName: '--fab' } as React.CSSProperties} popoverTarget="chat" />
<div id="chat" popover="auto" className={styles.chat} />
```

```css
.chat {
  position-anchor: --fab;
  bottom: calc(anchor(top) + 8px);
  right: anchor(right);
}
```

## Do not

- Reimplement focus trap with useEffect when dialog/popover suffices
- Use positive z-index wars instead of top layer (popover/dialog)
- Mix `showModal()` target with `popover` attribute on same element

Reference: https://developer.chrome.com/docs/web-platform/
