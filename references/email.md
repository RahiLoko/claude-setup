# Optional Module: Brevo Transactional Email

## Decisions

- Call Brevo's transactional API (`https://api.brevo.com/v3/smtp/email`) via plain `fetch` from one helper in `src/lib/email.ts` — the official SDK is heavyweight and unnecessary for send-only use.
- Helper exposes intent-named functions (`sendVerificationEmail`, `sendPasswordResetEmail`), not a generic `sendEmail` free-for-all.
- Wire into Better Auth's email hooks: email verification + password reset if chosen together with the auth baseline.
- Dev behavior: when `BREVO_API_KEY` is unset, log the email payload to console instead of sending — signup must work locally without a key.

## Env vars (add to .env.example with comments)

- `BREVO_API_KEY` — Brevo dashboard → SMTP & API → API keys
- `EMAIL_FROM` — verified sender, e.g. `noreply@<domain>`
- `EMAIL_FROM_NAME` — display name

## Verification additions

- With no key set: signup flow still completes locally and the payload appears in the dev-server log (this IS the auth round-trip check plus one log assertion).
- Real send is proven when the project gets a domain + verified sender — list as pending in the report.
