# nestjs-fullstack-turborepo-starter

Production-ready fullstack monorepo starter with **NestJS** API, **React** customer app, **React Admin** dashboard, and **Turborepo** for orchestration.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/novostudiotech/nestjs-fullstack-turborepo-starter/main/setup.sh | bash
```

Or clone first:

```bash
git clone https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git my-project
cd my-project
./setup.sh
```

The script asks for a project name, then:
1. Clones the template (if run via curl)
2. Pulls & detaches submodules (API becomes a regular directory)
3. Resets git history (one clean commit, no template baggage)
4. Configures workspace (all apps in pnpm workspaces)
5. Copies `.env.example` files
6. Installs dependencies
7. Starts Docker (PostgreSQL, Redis)
8. Deletes itself

After setup: clean `git status`, one commit, ready to code.

| App | URL |
|-----|-----|
| API | http://localhost:3000 |
| Customer App | http://localhost:5175 |
| Admin | http://localhost:5176 |

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
scripts/
  turbo-run.sh       — Turbo wrapper (resolves package names from directories)
  setup-worktree.sh  — Isolated feature development
setup.sh             — First-time setup (self-deletes after use)
```

## Commands

```bash
pnpm dev                      # Start all apps in parallel
pnpm build                    # Build everything
pnpm build api                # Build single app (resolves name from package.json)
pnpm build admin
pnpm build app
pnpm lint                     # Lint entire codebase (Biome)
pnpm test                     # Run all tests
pnpm api:generate             # Generate TypeScript API clients from OpenAPI spec
```

## What's Included

### Monorepo Infrastructure
- **Turborepo** — parallel builds with caching, task dependencies
- **pnpm workspaces** — shared dependencies
- **Biome** — fast linting and formatting (replaces ESLint + Prettier)
- **Husky + lint-staged** — pre-commit linting
- **commitlint** — Conventional Commits enforcement

### CI/CD (GitHub Actions)
- **CI** (on PRs): Build validation, lint, secret scanning. Unit/E2E test templates included.
- **CD** (on push to main): Change detection + conditional deploy. Configurable targets (Cloudflare Pages, Docker registry).

### Docker
- Multi-stage Dockerfile with `turbo prune` for efficient per-app images
- `docker-compose.yml` with PostgreSQL 16, test DB, and Redis 7

### Developer Workflow
- **Worktree isolation** — `./scripts/setup-worktree.sh feat/my-feature` creates an isolated copy with a unique API port
- **API client generation** — `pnpm api:generate` creates TypeScript clients from OpenAPI spec

## API (nestjs-starter)

The API is based on [novostudiotech/nestjs-starter](https://github.com/novostudiotech/nestjs-starter):

- NestJS 11 with TypeORM 0.3
- Better Auth (session-based + Email OTP)
- PostgreSQL 16+ (Neon-compatible)
- Zod validation
- E2E tests with Playwright
- Resend + React Email

See the [nestjs-starter docs](https://github.com/novostudiotech/nestjs-starter) for full API documentation.

## Code Style

Enforced via [Biome](https://biomejs.dev/) + Husky pre-commit hooks:

- 2 spaces, single quotes, semicolons, trailing commas (ES5), LF, 100 char width
- [Conventional Commits](https://www.conventionalcommits.org/) via commitlint

## License

MIT
