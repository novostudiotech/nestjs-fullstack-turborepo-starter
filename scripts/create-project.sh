#!/usr/bin/env bash
# Create a new project from the nestjs-fullstack-turborepo-starter template.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/novostudiotech/nestjs-fullstack-turborepo-starter/main/scripts/create-project.sh) my-project
#
#   Or after cloning:
#   ./scripts/create-project.sh
#
# What it does:
#   1. Clones the template (if run remotely)
#   2. Pulls in API submodule and detaches it (becomes a regular directory)
#   3. Resets git history (fresh start)
#   4. Renames packages to your project name
#   5. Installs all dependencies
#   6. Copies .env.example files
#   7. Starts Docker services (PostgreSQL, Redis)
#   8. Ready to develop

set -euo pipefail

REPO_URL="https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

step() { echo -e "\n${CYAN}${BOLD}[$1/$TOTAL_STEPS]${NC} $2"; }
ok()   { echo -e "  ${GREEN}done${NC}"; }
fail() { echo -e "  ${RED}$1${NC}"; exit 1; }

# ─── Determine mode: remote (curl | bash) or local (already in repo) ───

if [ -f "package.json" ] && grep -q "nestjs-fullstack-turborepo-starter" package.json 2>/dev/null; then
  # Running from inside the cloned repo
  MODE="local"
  PROJECT_DIR="$(pwd)"
  PROJECT_NAME="${1:-$(basename "$PROJECT_DIR")}"
  TOTAL_STEPS=7
else
  # Running remotely — need to clone first
  MODE="remote"
  PROJECT_NAME="${1:?Usage: $0 <project-name>}"
  PROJECT_DIR="$(pwd)/$PROJECT_NAME"
  TOTAL_STEPS=8

  if [ -d "$PROJECT_DIR" ]; then
    fail "Directory $PROJECT_DIR already exists"
  fi

  step 1 "Cloning template into ${BOLD}$PROJECT_NAME${NC}"
  git clone --recurse-submodules "$REPO_URL" "$PROJECT_NAME" --quiet
  cd "$PROJECT_DIR"
  ok
fi

# ─── Adjust step numbers based on mode ───
S=1
[ "$MODE" = "remote" ] && S=2

# ─── Detach submodules (API becomes a regular directory) ───

step $((S)) "Detaching submodules"
if [ -f ".gitmodules" ]; then
  # Get list of submodule paths
  submodule_paths=$(git config --file .gitmodules --get-regexp path | awk '{print $2}')

  for sub_path in $submodule_paths; do
    if [ -d "$sub_path" ]; then
      # Remove from git index but keep files
      git rm --cached "$sub_path" --quiet 2>/dev/null || true
      # Remove the .git file inside submodule
      rm -f "$sub_path/.git"
    fi
  done

  rm -f .gitmodules
  echo "  submodules detached: $submodule_paths"
else
  echo "  no submodules found"
fi
ok

# ─── Reset git history ───

step $((S + 1)) "Initializing fresh git history"
rm -rf .git
git init --quiet
git add -A
git commit -m "feat: initial project setup from nestjs-fullstack-turborepo-starter" --quiet
ok

# ─── Rename packages ───

step $((S + 2)) "Renaming project to ${BOLD}$PROJECT_NAME${NC}"

# Root package.json
if command -v node &>/dev/null; then
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.name = '$PROJECT_NAME';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  "
fi

# Add API to workspace (now that it's not a submodule)
cat > pnpm-workspace.yaml << 'YAML'
packages:
  - 'apps/*'
  - 'packages/*'
YAML

echo "  root: $PROJECT_NAME"
echo "  workspace: apps/* + packages/*"
ok

# ─── Copy .env files ───

step $((S + 3)) "Setting up environment files"
for env_example in $(find . -name '.env.example' -not -path '*/node_modules/*'); do
  env_file="${env_example%.example}"
  if [ ! -f "$env_file" ]; then
    cp "$env_example" "$env_file"
    echo "  $(echo "$env_file" | sed 's|^\./||')"
  fi
done
ok

# ─── Install dependencies ───

step $((S + 4)) "Installing dependencies"
if ! command -v pnpm &>/dev/null; then
  echo "  pnpm not found, installing via corepack..."
  corepack enable
  corepack prepare pnpm@latest --activate
fi

pnpm install 2>&1 | tail -5
ok

# ─── Start Docker services ───

step $((S + 5)) "Starting Docker services (PostgreSQL, Redis)"
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  docker compose up -d 2>&1 | tail -3
  ok
else
  echo "  skipped (Docker not running)"
fi

# ─── Done ───

echo ""
echo -e "${GREEN}${BOLD}Project ready!${NC}"
echo ""
echo -e "  ${BOLD}cd $PROJECT_NAME${NC}"
echo ""
echo "  pnpm dev              Start all apps"
echo "  pnpm build api        Build API"
echo "  pnpm build admin      Build admin"
echo "  pnpm build app        Build customer app"
echo ""
echo "  Apps:"
echo "    API:   http://localhost:3000"
echo "    App:   http://localhost:5175"
echo "    Admin: http://localhost:5176"
echo ""
echo "Next steps:"
echo "  1. Configure apps/api/.env (database, auth secrets)"
echo "  2. Run 'pnpm dev' to start developing"
echo "  3. Create a GitHub repo: gh repo create $PROJECT_NAME --private --source . --push"
