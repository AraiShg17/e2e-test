---
name: frontend-a11y-security
disable-model-invocation: true
description: >-
  Web accessibility and client-side security checks. Use for a11y audits,
  focus management, labels, env vars, XSS prevention, cookies, and CSP planning.
---

# Frontend A11y & Security

## Accessibility checklist

### Structure

- [ ] Landmarks: header, nav, main, footer
- [ ] One main, logical heading order
- [ ] Skip link to `#main` with `tabindex="-1"` on target
- [ ] Tables for data only, with `scope` and `caption`

### Names

- [ ] Every control has `<label for>` or `aria-labelledby`
- [ ] Icon-only buttons have accessible name (visible or `.visually-hidden`)
- [ ] No `placeholder`-as-label
- [ ] Field errors are connected with `aria-describedby`
- [ ] Invalid fields use `aria-invalid="true"`

### Keyboard

- [ ] All actions reachable by Tab
- [ ] `:focus-visible` styles present
- [ ] No `tabindex` > 0
- [ ] Modals use native dialog/popover focus handling
- [ ] Enter / Space behavior is preserved for buttons and controls

### Motion

- [ ] `prefers-reduced-motion: reduce` respected

### Contrast and targets

- [ ] Normal text contrast is at least 4.5:1
- [ ] Large text contrast is at least 3:1
- [ ] Icons, borders, focus rings, and chart marks have at least 3:1 contrast
- [ ] Pointer targets meet WCAG 2.2 24x24 CSS px minimum
- [ ] Practical touch targets are 44x44 CSS px or larger
- [ ] `pointer: coarse` styles increase tap target size and spacing

### Live feedback

- [ ] Save success, async errors, and toast messages use `aria-live`
- [ ] Critical errors use `role="alert"`
- [ ] Non-critical status uses `role="status"` / `aria-live="polite"`

## Security checklist

### Secrets

- [ ] No secrets in source or rules files
- [ ] `.env*` files are gitignored; `.env.example` contains names only, no real values
- [ ] Production secrets come from a secret manager / platform env config
- [ ] No API keys, DB URLs, OAuth secrets, JWT secrets, admin tokens, private URLs, customer names, or internal IDs in source/docs/rules/logs
- [ ] No credentials in `console.log`, analytics, error reporting, screenshots, or AI prompts
- [ ] Next.js `NEXT_PUBLIC_` vars contain only public values
- [ ] Secrets are read only in Server Components, Server Actions, Route Handlers, or server-only modules
- [ ] Secrets are not passed into Client Component props or browser bundles

Search before shipping:

```bash
rg -n "sk_live|secret|token|password|api[_-]?key|DATABASE_URL|PRIVATE_KEY|BEGIN .*PRIVATE KEY" .
```

### DOM XSS

- [ ] Untrusted data renders as text, not HTML
- [ ] Untrusted data includes user input, CMS HTML, Markdown output, external API data, URL params, and query strings
- [ ] No unsanitized `innerHTML`, `outerHTML`, `insertAdjacentHTML`, or `dangerouslySetInnerHTML`
- [ ] No `eval`, `new Function`, `document.write`, or string timers
- [ ] No `javascript:` URLs or unvalidated redirect targets
- [ ] If HTML rendering is required, sanitize first and pass only `sanitizedHtml`

### Cookies

- Prefer `__Host-` prefix with `Secure; HttpOnly; Path=/; SameSite=Lax`
- Do not store access tokens, refresh tokens, or session secrets in `localStorage`
- Prefer `SameSite=Lax` or `Strict` unless cross-site behavior is required

### Headers (incremental)

1. HTTPS + HSTS (start short max-age)
2. `frame-ancestors 'self'` or X-Frame-Options
3. CSP report-only → enforce after review

### postMessage

Always validate `event.origin` and payload shape; never use `*` for sensitive payloads.

## Performance (a11y-related)

- LCP image: no `loading="lazy"`, set `fetchpriority="high"`
- Set `width`/`height` to prevent CLS

## Visually hidden utility

```css
.visually-hidden:where(:not(:focus-within, :active)) {
  position: absolute !important;
  clip-path: inset(50%) !important;
  width: 1px !important;
  height: 1px !important;
  margin: -1px !important;
  overflow: hidden !important;
  border: 0 !important;
  white-space: nowrap !important;
}
```

## Error and status pattern

```html
<label for="email">Email</label>
<input id="email" type="email" aria-invalid="true" aria-describedby="email-error" />
<p id="email-error">Check the email address format.</p>

<p role="status" aria-live="polite" class="visually-hidden">Saved</p>
<p role="alert">Save failed</p>
```

```css
.tapTarget {
  min-inline-size: 44px;
  min-block-size: 44px;
}

@media (pointer: coarse) {
  .tapTarget {
    min-inline-size: 48px;
    min-block-size: 48px;
  }
}
```

References:
- https://developer.mozilla.org/
- https://web.dev/
- https://www.w3.org/WAI/standards-guidelines/wcag/
