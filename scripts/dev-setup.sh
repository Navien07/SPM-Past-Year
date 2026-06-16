#!/usr/bin/env bash
# Idempotent project bootstrap for fresh/ephemeral environments (e.g. Claude
# Code on the web). Installs deps and prepares the SQLite DB only when needed.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d node_modules ]; then
  echo "[setup] installing dependencies…"
  npm install --no-audit --no-fund
fi

# Ensure Prisma client + a seeded SQLite DB exist.
if [ ! -f prisma/dev.db ]; then
  echo "[setup] preparing database…"
  npx prisma generate >/dev/null
  npx prisma db push --skip-generate >/dev/null
  npx tsx prisma/seed.ts
else
  npx prisma generate >/dev/null 2>&1 || true
fi

echo "[setup] ready. Run: npm run dev"
