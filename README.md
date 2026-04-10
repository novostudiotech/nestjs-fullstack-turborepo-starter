# nestjs-fullstack-turborepo-starter

Production-ready fullstack monorepo starter with **NestJS** API, **React** customer app, **React Admin** dashboard, and **Turborepo** for orchestration.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 24+ |
| Language | TypeScript 5.7+ (strict mode) |
| API | [NestJS 11](https://github.com/novostudiotech/nestjs-starter) (PostgreSQL, TypeORM, Better Auth) |
| Customer App | React 19 + Vite 6 + Tailwind CSS 4 |
| Admin Dashboard | React Admin 5 + Material-UI 7 |
| Monorepo | Turborepo 2 + pnpm 10 workspaces |
| Linter/Formatter | Biome 2 |
| CI/CD | GitHub Actions |
| Containerization | Docker (multi-stage builds) |

## Structure

```
apps/
  api/       — NestJS backend (from novostudiotech/nestjs-starter)
  app/       — Customer-facing React dashboard (Vite + Tailwind)
  admin/     — Admin dashboard (React Admin + MUI)
packages/
  common/    — Shared utilities and types
scripts/     — Turbo runners, worktree setup, API client generation
```

## Quick Start

### 1. Create your project from this template

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git my-project
cd my-project

# Detach from template — make API a regular directory (not a submodule)
git rm --cached apps/api
rm .gitmodules
git add apps/api/
```

Now `apps/api` is a regular directory in your repo. Commit and start building.

### 2. Add API to workspace

Update `pnpm-workspace.yaml` to include the API:

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

Update `apps/api/package.json` name to match your project scope (e.g. `@my-project/api`).

### 3. Install and run

```bash
pnpm install

# Start infrastructure
docker compose up -d   # PostgreSQL + Redis

# Configure API
cp apps/api/.env.example apps/api/.env

# Start everything
pnpm dev
```

### Per-App Commands

```bash
pnpm --filter app dev       # Customer app  → http://localhost:5175
pnpm --filter admin dev     # Admin panel   → http://localhost:5176
pnpm --filter api dev       # API server    → http://localhost:3000
```

## What's Included

### Monorepo Infrastructure
- **Turborepo** — parallel builds with caching, task dependencies (`^build`)
- **pnpm workspaces** — shared dependencies, workspace protocol
- **Biome** — fast linting and formatting (replaces ESLint + Prettier)
- **Husky + lint-staged** — pre-commit linting
- **commitlint** — Conventional Commits enforcement

### CI/CD (GitHub Actions)
- **CI** (on PRs): Build validation, lint, secret scanning (TruffleHog). Unit/E2E test templates included as comments.
- **CD** (on push to main): Change detection + conditional deploy jobs. Deploy targets (Cloudflare Pages, Docker registry) are configurable.

### Docker
- Multi-stage Dockerfile with separate `api` and `frontend` targets
- `docker-compose.yml` with PostgreSQL 16, test DB, and Redis 7

### Developer Workflow
- **Worktree isolation** — `./scripts/setup-worktree.sh feat/my-feature` creates an isolated working copy with a unique API port (3100-3999)
- **API client generation** — `pnpm api:generate` creates TypeScript clients from OpenAPI spec

## API (nestjs-starter)

The API is based on [novostudiotech/nestjs-starter](https://github.com/novostudiotech/nestjs-starter):

- NestJS 11 with TypeORM 0.3
- Better Auth (session-based + Email OTP)
- PostgreSQL 16+ (Neon-compatible)
- Zod validation (not class-validator)
- E2E tests with Playwright
- Resend + React Email for transactional emails

See the [nestjs-starter docs](https://github.com/novostudiotech/nestjs-starter) for full API documentation.

## Scripts

| Command | Description |
|---------|-----------|
| `pnpm dev` | Start all apps in parallel |
| `pnpm build` | Build all workspace packages |
| `pnpm lint` | Lint entire codebase (Biome) |
| `pnpm api:generate` | Generate TypeScript API clients from OpenAPI spec |

## Code Style

Enforced via [Biome](https://biomejs.dev/) + Husky pre-commit hooks:

- 2 spaces, single quotes, semicolons, trailing commas (ES5), LF, 100 char line width
- [Conventional Commits](https://www.conventionalcommits.org/) via commitlint

## License

MIT
