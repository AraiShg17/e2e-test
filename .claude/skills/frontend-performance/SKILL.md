---
name: frontend-performance
disable-model-invocation: true
description: >-
  Chrome-first frontend performance guidance for INP, Long Tasks, scheduling,
  rendering deferral, image priority, analytics batching, and SPA transitions.
---

# Frontend Performance

Optimize for Core Web Vitals, especially INP. Move work out of the critical
input/rendering path and use Chrome-leading scheduling and rendering APIs.

## Rendering

- LCP image: no `loading="lazy"`, set `fetchpriority="high"`, `width`, `height`
- In Next.js prefer `next/image` with `priority` for LCP and explicit `sizes`
- Below-fold heavy sections: `content-visibility: auto`
- Prevent layout jumps with `contain-intrinsic-size`
- Use Server Components by default in Next.js; minimize client bundle size
- Fonts: `next/font/local` or `next/font/google`; subset for LCP font only

```tsx
import Image from 'next/image';

<Image
  src="/hero.webp"
  alt="Product overview"
  width={1200}
  height={630}
  priority
  sizes="(min-width: 768px) 1200px, 100vw"
/>
```

```css
.belowFoldSection {
  content-visibility: auto;
  contain-intrinsic-size: 800px;
}
```

## INP and Long Tasks

- Split synchronous work into chunks under 50ms
- Avoid large JSON parse, filtering, sorting, or DOM updates immediately after input
- Prefer `scheduler.postTask()` with priorities
- Fall back to `requestIdleCallback()` or `setTimeout()`
- Cancel stale async work with `AbortController`

```ts
type TaskPriority = 'user-blocking' | 'user-visible' | 'background';

export function scheduleTask(callback: () => void, priority: TaskPriority = 'user-visible') {
  const maybeScheduler = globalThis as typeof globalThis & {
    scheduler?: { postTask: (cb: () => void, options?: { priority?: TaskPriority }) => Promise<void> };
  };

  if (maybeScheduler.scheduler?.postTask) {
    return maybeScheduler.scheduler.postTask(callback, { priority });
  }

  return new Promise<void>((resolve) => {
    const run = () => {
      callback();
      resolve();
    };
    if ('requestIdleCallback' in globalThis) {
      requestIdleCallback(run);
      return;
    }
    setTimeout(run, 0);
  });
}
```

## Network and analytics

- Batch analytics events
- Use `navigator.sendBeacon()` for unload-safe sends
- Fallback to `fetch(..., { keepalive: true })`
- Deprioritize background fetches so they do not compete with LCP resources

```ts
export function sendAnalyticsBatch(payload: unknown) {
  const body = JSON.stringify(payload);
  if (navigator.sendBeacon) {
    navigator.sendBeacon('/analytics', new Blob([body], { type: 'application/json' }));
    return;
  }
  void fetch('/analytics', {
    method: 'POST',
    body,
    keepalive: true,
    headers: { 'content-type': 'application/json' },
  });
}
```

## SPA transitions

- Do not sync import heavy dependencies during route transitions
- Use View Transitions for visual continuity
- Respect `prefers-reduced-motion`
- Prefetch likely next route data and code without blocking the current interaction
