#!/usr/bin/env bash
# Idempotent project bootstrap for fresh/ephemeral environments (e.g. Claude
# Code on the web). Installs deps, starts a local Postgres, prepares + seeds
# the DB only when needed. Best-effort: never hard-fails the session.
set -uo pipefail
cd "$(dirname "$0")/.."

# 1. Dependencies
[ -d node_modules ] || npm install --no-audit --no-fund

# 2. Local Postgres (best effort; mirrors Supabase for local dev)
if command -v pg_ctlcluster >/dev/null 2>&1; then
  pg_lsclusters 2>/dev/null | grep -q online || pg_ctlcluster 16 main start 2>/dev/null || true
  su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='spm'\" | grep -q 1 \
    || psql -c \"CREATE ROLE spm LOGIN PASSWORD 'spm';\"" 2>/dev/null || true
  su - postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='spm'\" | grep -q 1 \
    || psql -c \"CREATE DATABASE spm OWNER spm;\"" 2>/dev/null || true
fi

# 3. Env
[ -f .env ] || cp .env.example .env

# 4. Prisma client + schema
npx prisma generate >/dev/null 2>&1 || true
npx prisma db push --skip-generate >/dev/null 2>&1 || true

# 5. Seed only if the DB looks empty
SUBJECTS=$(node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.subject.count().then(n=>{console.log(n);return p.\$disconnect()}).catch(()=>{console.log(0)})" 2>/dev/null || echo 0)
if [ "${SUBJECTS:-0}" = "0" ]; then
  echo "[setup] seeding database…"
  npx tsx prisma/seed.ts || true
fi

echo "[setup] ready. Run: npm run dev"
