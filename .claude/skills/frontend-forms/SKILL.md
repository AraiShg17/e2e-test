---
name: frontend-forms
disable-model-invocation: true
description: >-
  Chrome-first modern form implementation. Use for autofill, validation states,
  field-sizing, branded native controls, custom select picker experiments, and
  secure accessible form UX.
---

# Frontend Forms

Prefer native form controls and Chrome-leading form capabilities. Do not rebuild
standard inputs with divs unless the native control cannot satisfy the workflow.

## Required

- Every control has a visible `<label>` or `aria-labelledby`
- Use exact `autocomplete` tokens for sign-in, sign-up, address, and payment
- Use `inputmode`, `enterkeyhint`, `autocapitalize`, and `spellcheck` intentionally
- Do not use `placeholder` as a label
- Do not set `autocomplete="off"` for auth, address, or payment without a clear reason

## Chrome-first features

- `:user-valid` / `:user-invalid` for validation after user interaction
- `field-sizing: content` for textareas and compact inputs that should fit content
- `accent-color` for checkbox/radio/range brand alignment
- `color-scheme: light dark` for browser-generated UI
- `:autofill` / `input:autofill` for autofill visibility
- Custom select picker / `::picker()` patterns when target browsers support them

```html
<label for="email">Email</label>
<input
  id="email"
  name="email"
  type="email"
  autocomplete="email"
  enterkeyhint="next"
  required
/>
```

```css
:root {
  color-scheme: light dark;
  --red-600: #dc2626;
  --red-400: #f87171;
  --green-600: #16a34a;
  --green-400: #4ade80;
  --color-danger-border: light-dark(var(--red-600), var(--red-400));
  --color-success-border: light-dark(var(--green-600), var(--green-400));
}

.field {
  field-sizing: content;
  accent-color: var(--color-action-bg);
}

.field:user-invalid {
  border-color: var(--color-danger-border);
}

.field:user-valid {
  border-color: var(--color-success-border);
}

input:autofill {
  box-shadow: 0 0 0 100vmax color-mix(in oklab, var(--color-action-bg) 12%, Canvas) inset;
}
```

## Autofill tokens

- Sign in: `username`, `current-password`, `one-time-code`
- Sign up: `email`, `new-password`, `given-name`, `family-name`
- Address: `postal-code`, `address-line1`, `address-level1`, `country`
- Payment: `cc-name`, `cc-number`, `cc-exp`, `cc-csc`

## Do not

- Replace native validation with JS-only validation
- Hide errors visually without `aria-describedby`
- Build custom combobox/select controls unless native select is insufficient
