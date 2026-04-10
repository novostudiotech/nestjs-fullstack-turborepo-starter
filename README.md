# nestjs-fullstack-turborepo-starter

Production-ready fullstack monorepo starter with **NestJS** API, **React** customer app, **React Admin** dashboard, and **Turborepo** for orchestration.

## Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 24+ |
| Language | TypeScript 5.7 (strict mode) |
| API | NestJS 11 (PostgreSQL, TypeORM, Better Auth) |
| Customer App | React 19 + Vite 7 + Tailwind CSS 4 |
| Admin Dashboard | React Admin 5 + Material-UI 6 |
| Monorepo | Turborepo 2 + pnpm workspaces |
| Linter/Formatter | Biome 2 |
| CI/CD | GitHub Actions |
| Containerization | Docker (multi-stage) |

## Structure

```
apps/
  api/       — NestJS backend (git submodule → nestjs-starter)
  app/       — Customer-facing React dashboard
  admin/     — Admin dashboard (React Admin)
packages/
  common/    — Shared utilities and types
```

## Quick Start

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/novostudiotech/nestjs-fullstack-turborepo-starter.git
cd nestjs-fullstack-turborepo-starter

# Install dependencies
pnpm install

# Start infrastructure (PostgreSQL, Redis)
docker compose up -d

# Start all apps in dev mode
pnpm dev
```

### Individual Apps

```bash
pnpm --filter api dev          # API (port 3000)
pnpm --filter app dev          # Customer app (port 5175)
pnpm --filter admin dev        # Admin dashboard (port 5176)
```

## API Submodule

The API (`apps/api`) is a git submodule pointing to [novostudiotech/nestjs-starter](https://github.com/novostudiotech/nestjs-starter). This allows the API to evolve independently while being integrated into the monorepo.

```bash
# Update API to latest
git submodule update --remote apps/api

# After cloning without --recurse-submodules
git submodule init && git submodule update
```

See the [nestjs-starter README](https://github.com/novostudiotech/nestjs-starter) for API-specific setup and configuration.

## Scripts

| Command | Description |
|---------|-----------|
| `pnpm dev` | Start all apps in parallel |
| `pnpm build` | Build all apps |
| `pnpm lint` | Lint entire codebase (Biome) |
| `pnpm test` | Run all tests |
| `pnpm api:generate` | Generate API clients from OpenAPI spec |

## Worktree Development

For isolated feature development:

```bash
./scripts/setup-worktree.sh feat/my-feature
cd .worktrees/feat/my-feature
pnpm dev
```

Each worktree gets a unique API port (3100-3999) derived from the branch name, so multiple worktrees can run simultaneously.

## Docker

```bash
# Infrastructure only
docker compose up -d

# Build API image
docker build --target api --build-arg appName=api -t my-api .

# Build frontend image
docker build --target frontend --build-arg appName=app -t my-app .
```

## CI/CD

- **CI** (PRs): Build validation, unit tests, E2E tests, secret scanning
- **CD** (push to main): Configurable deployment for API (Docker), App and Admin (static hosting)

See `.github/workflows/` for details.

## Code Style

Enforced project-wide via Biome:
- 2 spaces, single quotes, semicolons, trailing commas (ES5), LF line endings
- Conventional Commits enforced via commitlint + Husky

## License

MIT
