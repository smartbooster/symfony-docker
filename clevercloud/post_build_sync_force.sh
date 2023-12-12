# Deploy Update
make deploy-revision
make orm-sync-force ENV=prod

# Frontend build
yarn install
make assets-build
