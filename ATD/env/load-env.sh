#!/bin/bash

# ============================================================
# load-env.sh - Load environment variables from .env files
# ============================================================
# Usage: source load-env.sh <environment>
#        source load-env.sh local
#        source load-env.sh dev
#        source load-env.sh staging
#        source load-env.sh prod
# ============================================================

set -o allexport

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ENV_FILE="${SCRIPT_DIR}/.env.${1:-local}"

# Validate environment argument
if [ -z "$1" ]; then
    echo "⚠️  No environment specified, using 'local' by default"
    ENV_FILE="${SCRIPT_DIR}/.env.local"
fi

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file not found: $ENV_FILE"
    echo "📁 Available environments in $SCRIPT_DIR:"
    ls -1 "$SCRIPT_DIR"/.env.* 2>/dev/null || echo "   No .env files found"
    return 1
fi

# Load environment file
echo "✅ Loading environment: $1"
source "$ENV_FILE"

# Display loaded environment
echo "📋 Environment variables loaded:"
echo "   ENV=$ENV"
echo "   BFF_URL=$BFF_URL"
echo "   FRONT_URL=$FRONT_URL"
echo "   KEYCLOAK_URL=$KEYCLOAK_URL"
echo "   DB_HOST=$DB_HOST"
echo "   SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE"
echo "   ANGULAR_ENV=$ANGULAR_ENV"

set +o allexport
