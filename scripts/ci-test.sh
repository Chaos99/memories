#!/bin/bash

# Install dependencies
cd apps/memories
npm ci
npx playwright install
cp ../../vue.zip .
unzip -qq vue.zip
cd ../..

# Speed up loads
php occ app:disable comments
php occ app:disable contactsinteraction:
php occ app:disable dashboard
php occ app:disable weather_status
php occ app:disable user_status
php occ app:disable updatenotification
php occ app:disable systemtags
php occ app:disable files_sharing

# Setup
cd apps/memories
make bin-ext
cd ../..

# Enable apps
php occ app:enable --force viewer
php occ app:enable --force memories

# Run repair steps
php occ maintenance:repair

set -e

# Set debug mode and start dev server
php occ config:system:set --type bool --value true debug
php -S localhost:8080 &

# Get test photo files
cd data/admin/files
wget https://github.com/pulsejet/memories-assets/raw/main/Files.zip
unzip Files.zip
cd ../../..

# Index
php occ files:scan --all
php occ memories:index

# Set admin timeline path
php occ user:setting admin memories timelinePath "/Photos"

# Run e2e tests
cd apps/memories
npm run e2e
cd ../..
