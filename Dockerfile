# syntax=docker/dockerfile:1
ARG nodeVersion=24

# Stage 0: base
FROM node:${nodeVersion}-alpine AS base
RUN apk add --no-cache libc6-compat bash && apk update

# Stage 0-1: turbo + pnpm
FROM base AS turbo
RUN npm install -g pnpm turbo

# Stage 1: prune workspace for target app
FROM turbo AS turbo_prune
ARG appName
WORKDIR /app
COPY . .
RUN turbo prune ${appName} --docker

# Stage 1-2: install deps from pruned lockfile
FROM turbo AS installer
WORKDIR /app
COPY --from=turbo_prune /app/out/json/ .
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# Stage 2: build
FROM turbo AS builder
ARG appName
ARG GIT_SHA=unknown
ARG GIT_BRANCH=unknown
ENV GIT_SHA=${GIT_SHA}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV VITE_API_URL=__VITE_API_URL__
WORKDIR /app
COPY --from=installer /app .
COPY --from=turbo_prune /app/out/full/ .
RUN npx turbo run build --filter=${appName}...

# Stage 2-1: install only production dependencies
FROM turbo AS prod_deps
WORKDIR /app
COPY --from=turbo_prune /app/out/json/ .
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile --prod --ignore-scripts

# Stage 3:A — API (NestJS)
FROM node:${nodeVersion}-alpine AS api

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

WORKDIR /app

COPY --from=prod_deps --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=prod_deps --chown=nestjs:nodejs /app/package.json ./package.json
COPY --from=builder --chown=nestjs:nodejs /app/apps/api/dist ./apps/api/dist
COPY --from=builder --chown=nestjs:nodejs /app/apps/api/package.json ./apps/api/package.json
COPY --from=prod_deps --chown=nestjs:nodejs /app/apps/api/node_modules ./apps/api/node_modules
COPY --from=builder --chown=nestjs:nodejs /app/packages ./packages

USER nestjs
WORKDIR /app/apps/api

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "dist/main"]

# Stage 3:B — Frontend (nginx)
FROM nginx:alpine AS frontend
ARG appName
COPY --from=builder /app/apps/${appName}/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
