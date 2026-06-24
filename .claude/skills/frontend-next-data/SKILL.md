---
name: frontend-next-data
disable-model-invocation: true
description: >-
  Next.js App Router data, cache, and mutation rules. Use for fetch cache
  policies, revalidatePath/revalidateTag, Server Actions, Route Handlers,
  dynamic data, and user-specific visibility.
---

# Frontend Next Data

Use this when implementing data fetching, Server Actions, Route Handlers, or
cache invalidation in Next.js App Router.

## Fetch policy

| Data | Policy |
|------|--------|
| Static CMS / marketing | `next: { revalidate: 3600 }` |
| Frequently changing list | tagged fetch + `revalidateTag()` |
| User-specific dashboard | `cache: 'no-store'` or dynamic route |
| Data immediately after mutation | Server Action + `revalidatePath()` / `revalidateTag()` |
| Auth/session-dependent | explicitly account for `cookies()` / `headers()` |

```ts
export async function fetchPosts() {
  const response = await fetch('https://example.com/posts', {
    next: { revalidate: 3600, tags: ['posts'] },
  });
  if (!response.ok) throw new Error('Failed to fetch posts');
  return response.json();
}
```

```ts
export async function fetchDashboard() {
  const response = await fetch('https://example.com/dashboard', {
    cache: 'no-store',
  });
  if (!response.ok) throw new Error('Failed to fetch dashboard');
  return response.json();
}
```

## Server Actions

- Action files use `'use server'`
- Validate input on the server
- Revalidate with `revalidatePath()` or `revalidateTag()` after mutation
- Do not mix redirect actions and state-returning actions casually
- Use idempotency keys for payment, create, and destructive mutations

```ts
'use server';

import { revalidateTag } from 'next/cache';
import { z } from 'zod';

const schema = z.object({
  title: z.string().min(1).max(120),
});

export async function createPost(_prevState: unknown, formData: FormData) {
  const parsed = schema.safeParse({
    title: formData.get('title'),
  });

  if (!parsed.success) {
    return { ok: false, message: 'Check the form values' };
  }

  await savePost(parsed.data);
  revalidateTag('posts');
  return { ok: true, message: 'Saved' };
}
```

## Route Handlers

- Create Route Handlers only for browser-facing BFF/API needs
- Do not fetch your own Route Handler from a Server Component; call the function directly
- GET needs a cache policy
- POST needs auth, CSRF/rate-limit consideration, and validation

## Do not

- Leave `fetch()` cache behavior implicit for important data
- Forget revalidation after mutation
- Put user-specific data in static cache
- Treat routes using `cookies()` / `headers()` as static by accident
