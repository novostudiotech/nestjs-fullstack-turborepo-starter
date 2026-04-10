#!/usr/bin/env bash
# Generate TypeScript API clients from the OpenAPI spec produced by the API app.
# Usage: pnpm api:generate

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
API_DIR="$ROOT_DIR/apps/api"
SPEC_FILE="$API_DIR/openapi.json"

echo "Generating OpenAPI spec..."
cd "$API_DIR"
pnpm exec ts-node -e "
const { NestFactory } = require('@nestjs/core');
const { SwaggerModule } = require('@nestjs/swagger');
const { AppModule } = require('./src/app.module');
const fs = require('fs');

async function generate() {
  const app = await NestFactory.create(AppModule, { logger: false });
  const config = new (require('@nestjs/swagger').DocumentBuilder)().build();
  const doc = SwaggerModule.createDocument(app, config);
  fs.writeFileSync('openapi.json', JSON.stringify(doc, null, 2));
  await app.close();
}
generate();
" 2>/dev/null || echo "Note: Adjust this script to match your API's Swagger setup."

if [ -f "$SPEC_FILE" ]; then
  echo "OpenAPI spec generated at $SPEC_FILE"

  # Generate clients for each frontend app that has orval config
  for app_dir in "$ROOT_DIR/apps/app" "$ROOT_DIR/apps/admin"; do
    if [ -f "$app_dir/orval.config.ts" ]; then
      echo "Generating client for $(basename "$app_dir")..."
      cd "$app_dir"
      pnpm exec orval
    fi
  done

  echo "API clients generated."
else
  echo "Skipped: No OpenAPI spec found. Start the API and re-run."
fi
