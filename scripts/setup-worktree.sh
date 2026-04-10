#!/usr/bin/env bash
# Setup a git worktree with .env files for isolated feature development.
#
# Usage: ./scripts/setup-worktree.sh <branch-name>
# Example: ./scripts/setup-worktree.sh feat/user-auth
#
# What it does:
# 1. Pulls latest main, creates git worktree at .worktrees/<branch-name>
# 2. Copies .env files from main tree to worktree
# 3. Assigns a unique API port (3100-3999) derived from branch name
# 4. Runs pnpm install + builds workspace packages

set -euo pipefail

BRANCH_NAME="${1:?Usage: $0 <branch-name>}"
ROOT_DIR="$(git rev-parse --show-toplevel)"
WORKTREE_DIR="$ROOT_DIR/.worktrees/$BRANCH_NAME"

# --- 1. Create worktree from latest main ---
if [ -d "$WORKTREE_DIR" ]; then
  echo "Worktree already exists at $WORKTREE_DIR"
else
  echo "Fetching latest main"
  git fetch origin main --quiet
  git merge origin/main --ff-only --quiet 2>/dev/null || true

  echo "Creating worktree at $WORKTREE_DIR"
  git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" 2>/dev/null || \
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
fi

# --- 2. Copy .env files ---
echo "Copying .env files"

if [ -f "$ROOT_DIR/.env" ]; then
  cp "$ROOT_DIR/.env" "$WORKTREE_DIR/.env"
fi

for app_dir in "$ROOT_DIR/apps/"*/; do
  app_name=$(basename "$app_dir")
  for env_file in "$app_dir".env "$app_dir".env.test "$app_dir".env.prod; do
    if [ -f "$env_file" ]; then
      dest="$WORKTREE_DIR/apps/$app_name/$(basename "$env_file")"
      cp "$env_file" "$dest"
      echo "  $(basename "$env_file") -> apps/$app_name/"
    fi
  done
done

# --- 3. Assign unique port (deterministic from branch name) ---
HASH=$(echo -n "$BRANCH_NAME" | cksum | awk '{print $1}')
PORT=$(( 3100 + (HASH % 900) ))

ENV_FILE="$WORKTREE_DIR/apps/api/.env"
if [ -f "$ENV_FILE" ] && grep -q "^PORT=" "$ENV_FILE"; then
  sed -i.bak "s|^PORT=.*|PORT=$PORT|" "$ENV_FILE"
  rm -f "$ENV_FILE.bak"
  echo "  API port set to $PORT"
fi

for frontend_env in "$WORKTREE_DIR/apps/app/.env" "$WORKTREE_DIR/apps/admin/.env"; do
  if [ -f "$frontend_env" ]; then
    sed -i.bak "s|http://localhost:3000|http://localhost:$PORT|g" "$frontend_env"
    rm -f "$frontend_env.bak"
  fi
done

# --- 4. Install dependencies + build workspace packages ---
echo "Installing dependencies"
cd "$WORKTREE_DIR"
pnpm install --frozen-lockfile 2>&1 | tail -3

echo "Building workspace packages"
pnpm --filter './packages/*' build 2>&1 | tail -3

# --- Done ---
echo ""
echo "Worktree ready at: $WORKTREE_DIR"
echo "  API port: $PORT"
echo ""
echo "Next steps:"
echo "  cd $WORKTREE_DIR"
echo "  pnpm dev"
