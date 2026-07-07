# Optional Module: Cloudflare R2 Storage

## Decisions

- Access R2 through its **S3-compatible API** with `@aws-sdk/client-s3` (+ `@aws-sdk/s3-request-presigner`).
- One client helper in `src/lib/storage.ts`; nothing else imports the AWS SDK directly.
- Upload pattern: server issues a **presigned PUT URL**; browser uploads directly to R2. Files never stream through the Next server.
- Object keys: `<feature>/<entityId>/<uuid>-<sanitized-filename>` — never trust the raw client filename.

## Env vars (add to .env.example with comments)

- `R2_ACCOUNT_ID` — Cloudflare account ID (dashboard → R2)
- `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` — R2 API token pair
- `R2_BUCKET` — bucket name
- `R2_PUBLIC_URL` — public bucket/custom-domain base URL, if the bucket is public

## DB backups to R2 (add once the project is live, not at scaffold)

- brickbox-new pattern: a compose sidecar (`alpine` + AWS CLI) runs daily
  `pg_dump | gzip` → `s3://<name>-backups/postgres/$(date +%F).sql.gz` against
  the R2 S3 endpoint, keeping the last 30. Use a **separate bucket** for
  backups (`R2_BUCKET_BACKUPS`) so asset-bucket credentials can stay
  narrower.

## Out of scope for the skill run

- Bucket creation, CORS rules on the bucket, and the API token are manual
  per-project steps in the Cloudflare dashboard. The report step must list
  them as pending setup.

## Verification additions

- None automated (no real bucket at scaffold time). Verify the helper
  module typechecks via `pnpm build`; real upload is proven with the first
  feature that uses it.
