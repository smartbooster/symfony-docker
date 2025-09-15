# Stop on error
set -e

# Deploy Update
make deploy-revision
make orm-sync-force ENV=prod
make orm-load-minimal ENV=prod
make orm-load-fake ENV=prod

# Frontend build
yarn install
make assets-build
