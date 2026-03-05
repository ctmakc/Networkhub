#!/usr/bin/env bash
# Run inside backend container or with backend virtualenv active
set -e

cd /app
echo "Running Alembic migrations..."
alembic upgrade head
echo "Migrations complete."
