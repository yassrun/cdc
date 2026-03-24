#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BFF_DIR="$ROOT_DIR/wkf-atd-bff"
FRONT_DIR="$ROOT_DIR/wkf-atd-front"
ENV_DIR="$ROOT_DIR/env"
COMPOSE_FILE="$ROOT_DIR/docker-compose.local.yml"

# Default environment
ENVIRONMENT="${ENVIRONMENT:-local}"

# Load environment variables from .env files
load_env() {
  local env_file="$ENV_DIR/.env.$ENVIRONMENT"
  
  if [[ ! -f "$env_file" ]]; then
    echo "ERROR: Environment file not found: $env_file"
    echo "Available environments:"
    ls -1 "$ENV_DIR"/.env.* 2>/dev/null || echo "  No .env files found"
    exit 1
  fi
  
  echo "📋 Loading environment: $ENVIRONMENT"
  set -o allexport
  source "$env_file"
  set +o allexport
  
  echo "   ✓ BFF_URL=$BFF_URL"
  echo "   ✓ FRONT_URL=$FRONT_URL"
  echo "   ✓ KEYCLOAK_URL=$KEYCLOAK_URL"
  echo "   ✓ DB_HOST=$DB_HOST"
}

TOOLS_DIR="${TOOLS_DIR:-$HOME/Desktop/tools}"
JAVA_HOME="${JAVA_HOME:-$TOOLS_DIR/jdk-17.0.18+8}"
NODE_HOME="${NODE_HOME:-$TOOLS_DIR/node-v20.19.0-win-x64}"

export JAVA_HOME
export PATH="$NODE_HOME:$JAVA_HOME/bin:$PATH"

usage() {
  cat <<'EOF'
Usage: ./run-local.sh [--env <environment>] <command>

Environments: local (default), dev, staging, prod

Commands:
  up-db           Start PostgreSQL + Keycloak (Docker)
  down-db         Stop all containers (Docker)
  build-back      Build BFF only
  build-front     Build Front only
  build-all       Build BFF + Front
  up              Start DB + services, then BFF, then Front (no build)
  deploy-local    Build all, then start all services

Examples:
  ./run-local.sh --env local build-all
  ./run-local.sh --env dev deploy-local
  ./run-local.sh up

Optional env vars:
  ENVIRONMENT     Environment name (default: local)
  TOOLS_DIR       Default: $HOME/Desktop/tools
  JAVA_HOME       Default: $TOOLS_DIR/jdk-17.0.18+8
  NODE_HOME       Default: $TOOLS_DIR/node-v20.19.0-win-x64
EOF
}

require_file() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$path" ]]; then
    echo "ERROR: $message ($path)"
    exit 1
  fi
}

check_prereqs() {
  require_file "$JAVA_HOME/bin/java" "JDK not found"
  require_file "$NODE_HOME/bin/node" "Node not found"
  require_file "$BFF_DIR/mvnw" "BFF Maven Wrapper not found"
  require_file "$FRONT_DIR/package.json" "Front package.json not found"
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is required to run local PostgreSQL + Keycloak."
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: docker daemon is not running. Start Docker Desktop first."
    exit 1
  fi

  require_file "$COMPOSE_FILE" "docker-compose.local.yml not found"
}

up_db() {
  require_docker
  echo "🗄️  Starting PostgreSQL + Keycloak containers..."
  docker compose -f "$COMPOSE_FILE" up -d postgres keycloak

  echo "⏳ Waiting for PostgreSQL on localhost:${DB_PORT:-5432} ..."
  local i
  for i in {1..40}; do
    if docker compose -f "$COMPOSE_FILE" exec -T postgres pg_isready -U "${DB_USER:-postgres}" -d "${DB_NAME:-postgres}" >/dev/null 2>&1; then
      echo "✅ PostgreSQL is ready"
      break
    fi
    sleep 2
  done

  echo "⏳ Waiting for Keycloak on localhost:${KEYCLOAK_PORT:-8080} ..."
  for i in {1..60}; do
    if curl -s -f "http://localhost:${KEYCLOAK_PORT:-8080}/health/ready" >/dev/null 2>&1; then
      echo "✅ Keycloak is ready"
      return 0
    fi
    sleep 2
  done

  echo "⚠️  Keycloak took longer than expected, but services may be functional"
  return 0
}

down_db() {
  require_docker
  echo "🛑 Stopping all containers..."
  docker compose -f "$COMPOSE_FILE" down
  echo "✅ All containers stopped"
}

build_back() {
  echo "🔨 Building BFF..."
  (
    cd "$BFF_DIR"
    ./mvnw -DskipTests clean package
  )
  echo "✅ BFF build complete"
}

build_front() {
  echo "🔨 Building Frontend..."
  (
    cd "$FRONT_DIR"
    npm install
    npm run build
  )
  echo "✅ Frontend build complete"
}

start_back() {
  echo "🚀 Starting BFF on ${BFF_URL}..."
  (
    cd "$BFF_DIR"
    ./mvnw spring-boot:run -Dspring-boot.run.profiles="${SPRING_PROFILES_ACTIVE:-local}"
  ) &
  BFF_PID=$!
}

start_front() {
  echo "🚀 Starting Frontend on ${FRONT_URL}..."
  (
    cd "$FRONT_DIR"
    npm start
  ) &
  FRONT_PID=$!
}

wait_services() {
  echo "📋 Running services:"
  echo "   BFF:  ${BFF_URL}"
  echo "   FRONT: ${FRONT_URL}"
  echo "   DB:   postgres://${DB_HOST}:${DB_PORT}/${DB_NAME}"
  echo "   Keycloak: ${KEYCLOAK_URL}"
  echo ""
  echo "Press Ctrl+C to stop all services"
  trap 'echo ""; echo "🛑 Stopping services..."; kill "$BFF_PID" "$FRONT_PID" 2>/dev/null || true; exit 0' INT TERM
  wait "$BFF_PID" "$FRONT_PID"
}

# Parse --env argument
if [[ $# -gt 0 && "$1" == "--env" ]]; then
  ENVIRONMENT="$2"
  shift 2
fi

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  load_env
  check_prereqs

  case "$1" in
    up-db)
      up_db
      ;;
    down-db)
      down_db
      ;;
    build-back)
      build_back
      ;;
    build-front)
      build_front
      ;;
    build-all)
      build_back
      build_front
      ;;
    up)
      up_db
      sleep 5
      start_back
      sleep 8
      start_front
      wait_services
      ;;
    deploy-local)
      up_db
      sleep 5
      build_back
      build_front
      start_back
      sleep 8
      start_front
      wait_services
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
