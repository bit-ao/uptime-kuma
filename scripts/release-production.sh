#!/usr/bin/env bash
#
# release-production.sh
#
# Rebuilds the `production` branch from the current `master` so that
# low-resource servers can deploy without running the frontend build.
#
# Flow:
#   1. Verify the working tree is clean.
#   2. Pull latest master from origin.
#   3. Switch to production, merge master.
#   4. npm ci (only if package-lock changed).
#   5. npm run build (Vite -> dist/).
#   6. Force-add dist/, commit, push origin/production.
#
# Run from anywhere inside the repo:
#     ./scripts/release-production.sh
#
# Deploy on the server:
#     git clone -b production https://github.com/bit-ao/uptime-kuma.git
#     cd uptime-kuma
#     npm ci --omit=dev --no-audit
#     npm run start-server

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GIT_AUTHOR_NAME_OVERRIDE="fgonga"
GIT_AUTHOR_EMAIL_OVERRIDE="fgonga16@gmail.com"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ok\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merr\033[0m %s\n' "$*" >&2; exit 1; }

git_as_me() {
    git -c "user.name=$GIT_AUTHOR_NAME_OVERRIDE" \
        -c "user.email=$GIT_AUTHOR_EMAIL_OVERRIDE" \
        "$@"
}

[[ -d .git ]] || die "Not a git repository: $REPO_ROOT"

if ! git diff --quiet || ! git diff --cached --quiet; then
    git status --short
    die "Working tree is dirty. Commit or stash before releasing."
fi

log "Fetching origin..."
git fetch origin --prune --quiet

log "Updating local master..."
git checkout --quiet master
git pull --ff-only --quiet origin master
master_sha=$(git rev-parse --short master)
ok "master @ $master_sha"

log "Switching to production..."
if git show-ref --verify --quiet refs/heads/production; then
    git checkout --quiet production
    git pull --ff-only --quiet origin production || true
else
    git checkout --quiet -b production origin/production
fi

if git merge-base --is-ancestor master HEAD; then
    ok "production already contains master."
else
    log "Merging master into production..."
    git_as_me merge --no-edit \
        -m "Merge master ($master_sha) into production" master
fi

if [[ ! -d node_modules ]] \
   || ! cmp -s package-lock.json node_modules/.package-lock.json 2>/dev/null; then
    log "Installing dependencies (npm ci)..."
    npm ci --no-audit --no-fund
else
    ok "node_modules already in sync with package-lock."
fi

log "Building frontend (vite)..."
npm run build

log "Staging dist/..."
git add -f dist

if git diff --cached --quiet; then
    ok "dist/ unchanged — nothing new to commit."
else
    git_as_me commit --quiet \
        -m "Rebuild dist/ from master @ $master_sha"
    ok "Committed rebuilt dist/."
fi

log "Pushing to origin/production..."
git push --quiet origin production

ok "Done → https://github.com/bit-ao/uptime-kuma/tree/production"
