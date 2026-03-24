# Environment Management Integration Guide

This document explains how environment variables flow through the entire ATD application stack.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  env/ Directory                                          │
│  ├── .env.local, .env.dev, .env.staging, .env.prod    │
│  ├── load-env.sh (Bash)                                │
│  └── load-env.ps1 (PowerShell)                         │
└─────────────────────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────┐
│  run-local.sh                                           │
│  ├── Loads .env.* file                                 │
│  ├── Sets PATH (JAVA_HOME, NODE_HOME)                 │
│  └── Orchestrates build/deployment                     │
└─────────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ↓               ↓               ↓
    ┌────────┐  ┌─────────────┐  ┌──────────────┐
    │ Maven  │  │ docker-      │  │ npm/ng build │
    │ Build  │  │ compose      │  │              │
    │        │  │              │  │              │
    │ BFF    │  │ PostgreSQL   │  │ Frontend     │
    │ .jar   │  │ Keycloak     │  │ dist/        │
    └────────┘  └─────────────┘  └──────────────┘
         │              │                │
         └──────────────┴────────────────┘
                        │
                        ↓
           ┌────────────────────────┐
           │ Running Services       │
           ├────────────────────────┤
           │ BFF :9090              │
           │ Frontend :4200         │
           │ PostgreSQL :5432       │
           │ Keycloak :8080         │
           └────────────────────────┘
```

## Variable Flow

### 1. Environment Loading (Shell)

**Bash**:
```bash
source ./env/load-env.sh local
# Exports: ENV=local, BFF_URL, DB_HOST, KEYCLOAK_URL, etc.
```

**PowerShell**:
```powershell
. ./env/load-env.ps1 local
# Sets env vars in current PowerShell session
```

### 2. Docker Compose Configuration

`.env.local` variables → `docker-compose.local.yml` substitution:

```yaml
services:
  postgres:
    environment:
      POSTGRES_DB: ${DB_NAME}              # From .env.local: postgres
      POSTGRES_USER: ${DB_USER}            # From .env.local: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}    # From .env.local: postgres
```

Start with:
```bash
docker compose -f docker-compose.local.yml up -d
# Docker uses variables from current shell environment
```

### 3. Java/Spring Boot (BFF)

Environment variables → Spring Boot application:

#### Via Java System Properties (Maven)
```bash
./mvnw spring-boot:run \
  -Dspring-boot.run.profiles=local \
  -Dspring.datasource.url=$SPRING_DATASOURCE_URL \
  -Dspring.security.oauth2.resourceserver.jwt.jwk-set-uri=$SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI
```

#### Via `application-local.yaml`
```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  security:
    oauth2:
      resourceserver:
        jwt:
          jwk-set-uri: ${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/certs
```

Spring resolves `${VAR_NAME}` from:
1. Java system properties
2. Environment variables
3. `application.yaml` properties

### 4. Angular/TypeScript (Frontend)

Variables built into the application at compile time:

**Build Time**:
```bash
npm run build --configuration development
# Uses src/environments/environment.dev.ts
```

**Environment File**:
```typescript
// src/environments/environment.dev.ts
export const environment = {
  production: false,
  apiUrl: '/api',  // Proxied to http://localhost:9090/api
  keycloakUrl: 'http://localhost:8080',
  keycloakRealm: 'realm_ce'
};
```

**Proxy Configuration** (`proxy.conf.json`):
```json
{
  "/api/*": {
    "target": "http://localhost:9090",
    "secure": false,
    "pathRewrite": { "^/api": "" },
    "changeOrigin": true
  }
}
```

## Complete Workflow Example

### Local Development (Full Deployment)

```bash
# 1. Change to project root
cd /path/to/ATD

# 2. Load environment variables
source ./env/load-env.sh local
# Exports: ENV=local, BFF_HOST=localhost, BFF_PORT=9090, DB_HOST=localhost, etc.

# 3. Run complete deployment
./run-local.sh deploy-local

# Step-by-step what happens:

# 3a. Start Docker containers
docker compose -f docker-compose.local.yml up -d postgres keycloak
# Uses variables:
#   - POSTGRES_DB=${DB_NAME}
#   - POSTGRES_USER=${DB_USER}
#   - POSTGRES_PASSWORD=${DB_PASSWORD}
#   - KEYCLOAK_PORT=${KEYCLOAK_PORT}

# 3b. Build BFF
cd wkf-atd-bff
./mvnw clean package
# Uses variables in pom.xml and is embedded in application.yaml

# 3c. Build Frontend
cd ../wkf-atd-front
npm install
npm run build
# Uses environment.ts (no env variables used at build time for local)

# 3d. Start BFF
cd ../wkf-atd-bff
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
# Starts on http://localhost:9090/api
# Connects to postgresql://localhost:5432

# 3e. Start Frontend
cd ../wkf-atd-front
npm start
# Serves on http://localhost:4200
# Proxies /api to http://localhost:9090

# 4. Access applications
# Frontend:  http://localhost:4200
# BFF:       http://localhost:9090/api
# Keycloak:  http://localhost:8080
# PostgreSQL: localhost:5432
```

## Development Server Deployment

```bash
# 1. Load dev environment
source ./env/load-env.sh dev
# Exports: DB_HOST=postgres-dev.sgmaroc.root.net, KEYCLOAK_URL=https://sso-dev.sgmaroc.root.net

# 2. Build applications
./run-local.sh --env dev build-all

# 3. Deploy to dev server (manual steps)
# - Copy BFF JAR to dev server
# - Copy frontend dist/ to dev web server
# - Configure reverse proxy to BFF
# - Set environment variables on dev server

# Example systemd service for BFF:
# [Service]
# Environment="SPRING_PROFILES_ACTIVE=dev"
# Environment="SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-dev.sgmaroc.root.net:5432/workflow_atd_dev"
# Environment="SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI=https://sso-dev.sgmaroc.root.net/realms/realm_ce_dev/protocol/openid-connect/certs"
# ExecStart=/usr/bin/java -jar /opt/wkf-atd/wkf-atd-bff.jar
```

## Variable Dependency Chain

```
.env.local
├── BFF_HOST, BFF_PORT
│   └─→ BFF_URL (computed)
│       └─→ run-local.sh start_back()
│           └─→ spring-boot:run
│               └─→ application-local.yaml
│                   └─→ HTTP Server :9090
│
├── DB_HOST, DB_PORT, DB_USER, DB_PASSWORD
│   └─→ SPRING_DATASOURCE_URL (computed)
│       └─→ docker-compose.yml postgres service
│           └─→ PostgreSQL Container
│               └─→ JDBC Connection from BFF
│
├── KEYCLOAK_HOST, KEYCLOAK_PORT, KEYCLOAK_REALM
│   └─→ KEYCLOAK_URL (computed)
│       └─→ SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI (computed)
│           └─→ application-local.yaml
│               └─→ Spring Security OAuth2 JWT validation
│
├── ANGULAR_ENV
│   └─→ npm run build
│       └─→ environment.{ts,dev.ts,prod.ts} selection
│           └─→ Angular build artifacts
│               └─→ Frontend bundle with API URLs
│
└── FRONT_PORT
    └─→ npm start
        └─→ Angular Dev Server :4200
            └─→ proxy.conf.json
                └─→ Transparent proxy to BFF
```

## Integration Points

### Build Time

1. **Maven** (`pom.xml`):
   - Versions from `pom.xml` (not env vars)
   - Dependencies resolved from Nexus repo
   - JAR artifact built

2. **npm/Angular** (`package.json`):
   - Dependencies from npm registry
   - Environment selection based on Angular CLI flag
   - Build outputs to `dist/`

### Runtime - Java

1. **Spring Boot**:
   - Reads `application-${SPRING_PROFILES_ACTIVE}.yaml`
   - Substitutes `${VAR_NAME}` from:
     - Environment variables
     - JVM system properties
     - application.yaml properties
   - Initializes connection pools, OAuth2, etc.

### Runtime - Docker

1. **docker-compose**:
   - Substitutes `${VAR_NAME}` from shell environment
   - Starts containers with those values as env vars
   - Containers run with their own env vars

### Runtime - Angular

1. **HTTP Requests**:
   - Frontend runs in browser
   - Makes requests to `/api/*` (relative)
   - Proxy in dev server (`npm start`) or nginx in prod
   - Requests routed to BFF based on environment

## Managing Secrets

### Development (Local)

Secrets hardcoded in `.env.local`:
```env
DB_PASSWORD=postgres
KEYCLOAK_CLIENT_SECRET=00ec8d04-2c89-4a64-9dd3-5930139b710e
```

⚠️ **Do NOT commit to git!**

Use `.gitignore`:
```
env/.env.local
env/.env.*.local
```

### Production

Use external secret management:

**AWS Secrets Manager**:
```yaml
# application-prod.yaml
spring:
  datasource:
    password: ${aws:secrets:atd-db-password:password}
```

**HashiCorp Vault**:
```yaml
spring:
  datasource:
    password: ${vault:secret/data/atd#password}
```

**Kubernetes Secrets**:
```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: wkf-atd-db
data:
  password: cG9zdGdyZXM=  # base64 encoded
---
apiVersion: apps/v1
kind: Deployment
spec:
  spec:
    containers:
    - name: bff
      env:
      - name: SPRING_DATASOURCE_PASSWORD
        valueFrom:
          secretKeyRef:
            name: wkf-atd-db
            key: password
```

## Troubleshooting Integration

### BFF can't connect to PostgreSQL

1. Check variable expanded correctly:
   ```bash
   echo $SPRING_DATASOURCE_URL
   # Should output: jdbc:postgresql://localhost:5432/postgres?currentSchema=template
   ```

2. Check Docker container running:
   ```bash
   docker ps | grep postgres
   # Should show wkf-atd-postgres container
   ```

3. Check network connectivity:
   ```bash
   docker compose -f docker-compose.local.yml exec postgres \
     psql -U postgres -c '\l'
   ```

### Frontend can't reach BFF

1. Check proxy configuration:
   ```bash
   cat wkf-atd-front/proxy.conf.json
   # Should have /api/* → localhost:9090
   ```

2. Check BFF is running:
   ```bash
   curl http://localhost:9090/api/health
   # Should respond with 200 OK
   ```

3. Check Angular build environment:
   ```bash
   cat wkf-atd-front/src/environments/environment.dev.ts
   # Should have apiUrl: '/api'
   ```

### Keycloak not accessible

1. Check container running:
   ```bash
   docker ps | grep keycloak
   docker logs wkf-atd-keycloak
   ```

2. Check variable loaded:
   ```bash
   echo $KEYCLOAK_URL
   # Should output: http://localhost:8080
   ```

3. Check health:
   ```bash
   curl http://localhost:8080/health/ready
   ```

## Summary

The environment management system:

1. **Centralizes** all configuration in `env/.env.*` files
2. **Loads** variables into shell environment via `load-env.sh`
3. **Substitutes** variables in:
   - Docker Compose (`${VAR_NAME}`)
   - Spring Boot (`${VAR_NAME}` in YAML)
   - Angular (at build time via environment files)
4. **Orchestrates** builds and deployment via `run-local.sh`
5. **Enables** easy switching between local, dev, staging, and production environments

All you need to do is:
```bash
source ./env/load-env.sh <environment>
./run-local.sh deploy-local
```
