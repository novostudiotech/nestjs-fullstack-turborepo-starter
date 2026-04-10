#!/usr/bin/env bash
# Create a new project from the nestjs-fullstack-turborepo-starter template.
#
# Remote (recommended):
#   curl -fsSL https://raw.githubusercontent.com/novostudiotech/nestjs-fullstack-turborepo-starter/main/setup.sh | bash -s my-project
#
# Or clone first, then run from inside:
#   git clone https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git my-project
#   cd my-project && ./setup.sh
#
# The script self-deletes after setup. You get a clean repo with one commit.

set -euo pipefail

REPO_URL="https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

step() { echo -e "\n${CYAN}${BOLD}[$1/$TOTAL]${NC} $2"; }

# ─── Detect mode ───

if [ -f "package.json" ] && grep -q "nestjs-fullstack-turborepo-starter" package.json 2>/dev/null; then
  # Already inside the cloned repo
  MODE="local"
  DEFAULT_NAME=$(basename "$(pwd)")

  if [ -n "${1:-}" ]; then
    PROJECT_NAME="$1"
  else
    echo -en "${BOLD}Project name${NC} ${DIM}($DEFAULT_NAME)${NC}: "
    read -r PROJECT_NAME
    PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"
  fi

  TOTAL=7
else
  # Remote — need to clone first
  MODE="remote"

  if [ -n "${1:-}" ]; then
    PROJECT_NAME="$1"
  else
    echo -en "${BOLD}Project name${NC}: "
    read -r PROJECT_NAME
    [ -z "$PROJECT_NAME" ] && { echo "Error: project name required"; exit 1; }
  fi

  TOTAL=8

  [ -d "$PROJECT_NAME" ] && { echo "Error: $PROJECT_NAME already exists"; exit 1; }

  step 1 "Cloning template"
  git clone --recurse-submodules "$REPO_URL" "$PROJECT_NAME" --quiet
  cd "$PROJECT_NAME"
  echo -e "  ${DIM}$PROJECT_NAME/${NC}"
fi

# Step offset (remote mode starts at 2)
O=1; [ "$MODE" = "remote" ] && O=2

# ─── Pull submodules (if cloned without --recurse-submodules) ───

step $O "Fetching submodules"
if [ -f ".gitmodules" ]; then
  git submodule init --quiet 2>/dev/null || true
  git submodule update --quiet 2>/dev/null || true
  echo -e "  ${DIM}done${NC}"
fi

# ─── Detach submodules ───

step $((O + 1)) "Detaching submodules"
if [ -f ".gitmodules" ]; then
  submodule_paths=$(git config --file .gitmodules --get-regexp path | awk '{print $2}')
  for sub_path in $submodule_paths; do
    if [ -d "$sub_path" ]; then
      git rm --cached "$sub_path" --quiet 2>/dev/null || true
      rm -f "$sub_path/.git"
      echo -e "  ${DIM}$sub_path${NC}"
    fi
  done
  rm -f .gitmodules
fi

# ─── Fresh git history ───

step $((O + 2)) "Fresh git history"
rm -rf .git
git init --quiet
echo -e "  ${DIM}clean slate${NC}"

# ─── Configure workspace ───

step $((O + 3)) "Configuring workspace"

node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.name = '$PROJECT_NAME';
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

cat > pnpm-workspace.yaml << 'YAML'
packages:
  - 'apps/*'
  - 'packages/*'
YAML

echo -e "  ${DIM}package: $PROJECT_NAME${NC}"
echo -e "  ${DIM}workspace: apps/* + packages/*${NC}"

# ─── Environment files ───

step $((O + 4)) "Copying .env files"
found_env=false
while IFS= read -r env_example; do
  env_file="${env_example%.example}"
  if [ ! -f "$env_file" ]; then
    cp "$env_example" "$env_file"
    echo -e "  ${DIM}$(echo "$env_file" | sed 's|^\./||')${NC}"
    found_env=true
  fi
done < <(find . -name '.env.example' -not -path '*/node_modules/*')
[ "$found_env" = false ] && echo -e "  ${DIM}none found${NC}"

# ─── Install dependencies ───

step $((O + 5)) "Installing dependencies"
if ! command -v pnpm &>/dev/null; then
  echo -e "  ${DIM}enabling pnpm via corepack...${NC}"
  corepack enable
  corepack prepare pnpm@latest --activate
fi
pnpm install 2>&1 | tail -3

# ─── Docker + cleanup ───

step $((O + 6)) "Finishing up"

if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  docker compose up -d 2>&1 | tail -3
else
  echo -e "  ${DIM}Docker not running — start later: docker compose up -d${NC}"
fi

rm -- "$0"
git add -A
git commit -m "feat: initial project setup" --quiet
echo -e "  ${DIM}setup.sh removed, initial commit created${NC}"

# ─── Done ───

echo ""
echo -e "${GREEN}${BOLD}Ready!${NC}"
echo ""
if [ "$MODE" = "remote" ]; then
  echo -e "  ${BOLD}cd $PROJECT_NAME${NC}"
fi
echo -e "  ${BOLD}pnpm dev${NC}"
echo ""
echo "  API:   http://localhost:3000"
echo "  App:   http://localhost:5175"
echo "  Admin: http://localhost:5176"
echo ""
echo -e "${DIM}Next: edit apps/api/.env, then 'gh repo create $PROJECT_NAME --private --source . --push'${NC}"
