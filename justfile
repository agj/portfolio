@_default:
  just --list --unsorted

# Run development server.
develop: install
  pnpm exec gulp develop

# Build for deployment.
build: install
  pnpm exec gulp build

# Build for debugging.
build-debug: install
  pnpm exec gulp debug

# Generate media cache.
cache: install
  pnpm exec gulp cache

# Build and deploy to server. Needs .env variables to be set.
deploy: build
  bash ./source/scripts/deploy.sh

[private]
install:
  pnpm install
