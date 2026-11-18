# Stop on error
set -e

# Deploy Update
make deploy-revision
make update ENV=prod

# Frontend build
npm ci
make assets-build
