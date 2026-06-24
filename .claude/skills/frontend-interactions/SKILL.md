---
name: frontend-interactions
disable-model-invocation: true
description: >-
  Interaction and API state patterns for optimistic UI, pending states,
  debounce/throttle, duplicate-submit prevention, stale request cancellation,
  rollback, and accessible async feedback.
---

# Frontend Interactions

Use this when UI triggers network mutation, search, autosave, filtering, or any
async action. Design interaction state before writing the component.

## Decision table

| Situation | Pattern |
|-----------|---------|
| Search input / autosave | debounce |
| Scroll / resize / pointermove | throttle or `requestAnimationFrame` |
| Submit / destructive action | pending lock + idempotency key |
| Fast mutation feedback | optimistic UI + rollback |
| Stale request risk | `AbortController` / sequence id |
| Async result announcement | `aria-live` / toast |

## React mutation pattern

- Use `useOptimistic` for instant UI feedback
- Use `useTransition` for pending state
- Use `useActionState` for form actions
- Disable duplicate submit while pending
- Roll back or revalidate server state on failure

```tsx
'use client';
import { useOptimistic, useTransition } from 'react';
import { likePost } from './actions';

export function LikeButton({ postId, liked, count }: { postId: string; liked: boolean; count: number }) {
  const [isPending, startTransition] = useTransition();
  const [optimistic, setOptimistic] = useOptimistic(
    { liked, count },
    (state) => ({
      liked: !state.liked,
      count: state.liked ? state.count - 1 : state.count + 1,
    }),
  );

  return (
    <button
      type="button"
      aria-pressed={optimistic.liked}
      disabled={isPending}
      onClick={() => {
        startTransition(async () => {
          setOptimistic();
          await likePost(postId);
        });
      }}
    >
      {optimistic.liked ? 'Liked' : 'Like'} {optimistic.count}
    </button>
  );
}
```

## Debounce

```ts
export function debounce<T extends (...args: never[]) => void>(callback: T, delay = 300) {
  let timer: ReturnType<typeof setTimeout> | undefined;

  return (...args: Parameters<T>) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => callback(...args), delay);
  };
}
```

## Throttle

```ts
export function throttle<T extends (...args: never[]) => void>(callback: T, wait = 100) {
  let last = 0;
  let trailing: ReturnType<typeof setTimeout> | undefined;

  return (...args: Parameters<T>) => {
    const now = Date.now();
    const remaining = wait - (now - last);

    if (remaining <= 0) {
      if (trailing) clearTimeout(trailing);
      trailing = undefined;
      last = now;
      callback(...args);
      return;
    }

    if (!trailing) {
      trailing = setTimeout(() => {
        last = Date.now();
        trailing = undefined;
        callback(...args);
      }, remaining);
    }
  };
}
```

## Abort stale requests

```ts
let searchController: AbortController | undefined;

export async function searchUsers(query: string) {
  searchController?.abort();
  searchController = new AbortController();

  const response = await fetch(`/api/search?q=${encodeURIComponent(query)}`, {
    signal: searchController.signal,
  });

  if (!response.ok) throw new Error('Search failed');
  return response.json();
}
```

## Do not

- Fire a request on every keystroke without debounce
- Submit a mutation multiple times while pending
- Show optimistic success without rollback or revalidation
- Ignore stale responses from older requests
- Announce async results visually only
