---
name: frontend-directory
disable-model-invocation: true
description: >-
  Defines Next.js App Router folder structure, feature colocation, and
  container/presentation boundaries. Use when creating routes, components,
  hooks, server actions, API helpers, or deciding where to place files in app/,
  features/, components/, or lib/.
---

# Frontend Directory Structure

## When to apply

- New component, hook, or API function
- New Next.js route or route group
- Deciding container vs presentation component boundaries
- Refactoring scattered files into cohesive folders
- Code review of import paths crossing too many top-level dirs

## Rules

### Next.js App Router ownership

Keep `app/` thin. It owns URL structure, layouts, metadata, and route boundaries.
Feature implementation lives in `features/`.

```
/app          # routes, layouts, loading/error, metadata
/features     # domain/feature owned UI + hooks + server actions
/components   # shared, domain-free UI
/lib          # shared utils, data clients, validators
/public
/styles       # globals.css
```

- `page.tsx` composes the feature container; do not put a full screen implementation there
- `layout.tsx` owns shell/provider/navigation boundaries
- `loading.tsx`, `error.tsx`, and `not-found.tsx` stay near the route
- Route groups such as `(marketing)`, `(app)`, `(auth)` create non-URL structure
- Private folders such as `_components`, `_lib`, `_actions` are route-private
- Server Components by default; push `'use client'` down to leaf components

### Parallel Routes

Use Parallel Routes only when multiple areas inside the same layout need to be
independent route slots. Do not use them for ordinary two-column layout,
dashboard cards, or simple component composition.

Good fits:

- List + URL-addressable detail modal / side panel
- Dashboard main / activity / analytics slots with independent loading/error
- Role- or segment-based slot replacement inside one layout
- Modal flows with Intercepting Routes and browser back behavior

Rules:

- Name slots by purpose, e.g. `@activity`, `@analytics`, `@details`
- Add `default.tsx` for each slot so hard navigation / refresh has a fallback
- Add slot-level `loading.tsx` / `error.tsx` when the slot fetches independently
- Avoid tightly coupled state between slots; prefer URL, server data, or explicit client state

### Colocate by component

```
/features/dashboard/
  DashboardContainer.tsx
  DashboardView.tsx
  DashboardView.module.css
  actions/updateDashboard.ts
  api/fetchDashboard.ts
  hooks/useDashboardFilters.ts
  types.ts

/components/Card/
  Card.tsx              # domain-free shared UI
  Card.module.css
  types.ts
```

### Container / Presentation

Separate data access, permissions, URL interpretation, and mutations from
HTML/CSS rendering. The goal is testability, replaceability, and preventing AI
agents from mixing business logic into visual components. Do not split every
tiny static component mechanically, but features with data access or state
updates should have a container / presentation boundary.

| Layer | Role | Location |
|-------|------|----------|
| Route | URL, metadata, layout boundary, feature call | `app/**/page.tsx` |
| Container | fetch, permissions, URL params, Server Action wiring | `features/name/NameContainer.tsx` |
| Presentation | render from props with semantic HTML/CSS | `features/name/NameView.tsx` |
| Shared UI | domain-free reusable UI | `components/` |
| Shared infra | data client, schema, formatters, auth helpers | `lib/` |

```tsx
// app/(app)/dashboard/page.tsx
import { DashboardContainer } from '@/features/dashboard/DashboardContainer';

export default function Page() {
  return <DashboardContainer />;
}
```

```tsx
// features/dashboard/DashboardContainer.tsx
import { fetchDashboard } from './api/fetchDashboard';
import { DashboardView } from './DashboardView';

export async function DashboardContainer() {
  const data = await fetchDashboard();
  return <DashboardView data={data} />;
}
```

Presentation components render from props and return user intent through
callbacks. They do not directly import `fetch()`, DB clients, cookie/session
helpers, Server Action implementations, permission checks, or URL param parsing.

### Never

- Put component-specific hooks at `/hooks/useCard.ts`
- Put component-specific API at `/api/submitForm.ts` when only one form uses it
- Put feature-specific UI in `/components`
- Put large screen implementation directly in `app/**/page.tsx`
- Add `'use client'` to a route/container when only one child needs client state

### Decision flow

1. URL boundary? → `app/`
2. Belongs to one feature/domain? → `features/name/`
3. Belongs to one route only? → `app/**/_components`, `_lib`, `_actions`
4. Domain-free reusable UI? → `components/`
5. Shared logic/data client/schema? → `lib/`
6. One component only? → colocate under that component folder

## Component file pair

```
ComponentName.tsx
ComponentName.module.css
```

Add `README.md` in the folder only when the component is complex.

## TypeScript export

```tsx
interface CardProps {
  title: string;
}

export function Card({ title }: CardProps) {
  return <article className={styles.card}>{title}</article>;
}
```

Use `'use client'` only when using state, effects, or browser APIs.
