# Stop on error
set -e

# Deploy Update
make deploy-revision
make orm-sync-force ENV=prod

# Frontend build
npm ci
make assets-build
