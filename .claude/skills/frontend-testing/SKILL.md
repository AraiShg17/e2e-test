---
name: frontend-testing
disable-model-invocation: true
description: >-
  Vitest and Testing Library patterns for component and unit tests. Use when
  writing or reviewing frontend tests, mocking fetch/Server Actions, or
  choosing query priorities (getByRole, userEvent).
---

# Frontend Testing

Use when the project adopts Vitest + Testing Library. Test behavior and
accessible names, not implementation details.

## Query priority

1. `getByRole` / `findByRole` with accessible name
2. `getByLabelText`
3. `getByText` for static copy
4. `data-testid` only as last resort

## Async and interaction

- Use `@testing-library/user-event` (`userEvent.setup()`)
- Async UI: `findBy*` or `waitFor`
- Avoid snapshot-only tests

## Component boundaries

- Test props and user-visible behavior
- Do not assert on CSS module class strings or private state
- Client Components: events, forms, optimistic UI states
- Server Components: thin composition tests; mock data loaders

## Next.js

- Mock `next/navigation` (`redirect`, `useRouter`, `usePathname`)
- Server Actions: validate input schema and mock `revalidatePath` / `revalidateTag`
- Page-level E2E belongs in Playwright (if adopted); this skill focuses on unit/component tests

## Network

- MSW or `vi.stubGlobal('fetch')` for API-dependent UI
- Cover success, error, pending, and empty states

## Accessibility checks

- Critical flows: `jest-axe` or `@axe-core/playwright` when available

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SaveButton } from './SaveButton';

it('submits with accessible name', async () => {
  const user = userEvent.setup();
  const onSave = vi.fn();
  render(<SaveButton onSave={onSave} />);
  await user.click(screen.getByRole('button', { name: 'Save' }));
  expect(onSave).toHaveBeenCalledOnce();
});
```
