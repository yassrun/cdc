# Environment Configuration

This directory contains environment-specific configuration files for the ATD (Workflow) application.

## Structure

```
env/
├── .env.local       # Local development (localhost)
├── .env.dev         # Development environment (recette)
├── .env.staging     # Staging (pre-production)
├── .env.prod        # Production
├── .env.example     # Template with all available variables
├── load-env.sh      # Bash script to load environment variables
└── load-env.ps1     # PowerShell script to load environment variables
```

## Quick Start

### Option 1: Load Environment Variables (Bash)

```bash
# From the root project directory
source ./env/load-env.sh local

# Then use run-local.sh
./run-local.sh deploy-local
```

### Option 2: Using `--env` flag

```bash
# run-local.sh automatically loads the specified environment
./run-local.sh --env local deploy-local
./run-local.sh --env dev build-all
```

### Option 3: Load Environment Variables (PowerShell)

```powershell
# From the project root
. ./env/load-env.ps1 local

# Then use commands with those variables
# Or run the Windows batch equivalent
```

## Environment Files

Each `.env.*` file contains:

- **BFF Configuration**: Backend server port, context path, URL
- **Frontend Configuration**: Angular environment, port
- **Database**: PostgreSQL host, port, credentials
- **Keycloak**: OAuth2/OIDC server, realm, client credentials
- **External APIs**: GED, Notification, BPM Adapter URLs
- **Logging**: Log levels by component
- **Proxy**: Corporate proxy settings (CNTLM)

### Variables Reference

| Variable | Purpose | Local | Dev | Staging | Prod |
|----------|---------|-------|-----|---------|------|
| `BFF_HOST` | Backend host | localhost | localhost | wkf-atd-bff-staging.sgmaroc.root.net | wkf-atd-bff.sgmaroc.root.net |
| `BFF_PORT` | Backend port | 9090 | 9090 | 443 | 443 |
| `FRONT_PORT` | Frontend port | 4200 | 4200 | 443 | 443 |
| `DB_HOST` | PostgreSQL host | localhost | postgres-dev.sgmaroc.root.net | postgres-staging.sgmaroc.root.net | postgres-prod.sgmaroc.root.net |
| `KEYCLOAK_HOST` | Keycloak host | localhost | sso-dev.sgmaroc.root.net | sso-staging.sgmaroc.root.net | sso.sgmaroc.root.net |
| `SPRING_PROFILES_ACTIVE` | Spring profiles | local | dev | staging | prod |

## Workflows

### Local Development Workflow

1. **Load environment**:
   ```bash
   source ./env/load-env.sh local
   ```

2. **Start services** (PostgreSQL + Keycloak + BFF + Front):
   ```bash
   ./run-local.sh deploy-local
   ```

3. **Access applications**:
   - Frontend: http://localhost:4200
   - BFF: http://localhost:9090/api
   - Keycloak: http://localhost:8080

### Development Server Workflow

1. **Load development environment**:
   ```bash
   source ./env/load-env.sh dev
   ```

2. **Build applications**:
   ```bash
   ./run-local.sh --env dev build-all
   ```

3. **Deploy to development server** (manual, not included in script)

## Environment Variables in Application Code

### Java/Spring Boot

Variables are injected via `@Value` or application properties:

```yaml
# application-local.yaml
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

core:
  api:
    ged:
      url: ${CORE_API_GED_URL}
    notification:
      url: ${CORE_API_NOTIFICATION_URL}
```

### Angular/TypeScript

Variables are injected at build time via environment files:

```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:9090/api',
  keycloakUrl: 'http://localhost:8080',
  keycloakRealm: 'realm_ce'
};
```

## Docker Compose Integration

The `docker-compose.local.yml` uses variables from `.env.local`:

```yaml
services:
  postgres:
    environment:
      POSTGRES_DB: ${DB_NAME:-postgres}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
```

Load environment before starting Docker services:

```bash
source ./env/load-env.sh local
docker compose -f docker-compose.local.yml up -d
```

Or use `run-local.sh` which handles this automatically.

## Security Notes

⚠️ **Important**:

1. **Never commit secrets** to `.env.*` files in version control
2. Use `.env.example` as a template for new environments
3. For production, use secure secret management (AWS Secrets Manager, HashiCorp Vault, etc.)
4. Database and Keycloak credentials should be rotated regularly
5. Keep `KEYCLOAK_CLIENT_SECRET` and `DB_PASSWORD` secure

## Troubleshooting

### Variables not loading

**Bash**:
```bash
# Verify the file exists
ls -la ./env/.env.local

# Test source directly
source ./env/.env.local
echo $BFF_URL
```

**PowerShell**:
```powershell
# Verify execution policy
Get-ExecutionPolicy

# If restricted, allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Test loading
. ./env/load-env.ps1 local
$env:BFF_URL
```

### Docker containers not starting

```bash
# Check if Docker is running
docker ps

# Check docker-compose syntax
docker compose -f docker-compose.local.yml config

# Check environment variable expansion
docker compose -f docker-compose.local.yml config | grep POSTGRES

# View logs
docker compose -f docker-compose.local.yml logs postgres
```

## Creating New Environments

1. Copy `.env.example`:
   ```bash
   cp ./env/.env.example ./env/.env.newenv
   ```

2. Edit the file with your values:
   ```bash
   nano ./env/.env.newenv
   ```

3. Use it in `run-local.sh`:
   ```bash
   ./run-local.sh --env newenv deploy-local
   ```

## Related Files

- [run-local.sh](../run-local.sh) - Build and deployment orchestration script
- [docker-compose.local.yml](../docker-compose.local.yml) - Docker Compose configuration
- [ATD/wkf-atd-bff](../wkf-atd-bff/) - Backend source with `application-*.yaml` files
- [ATD/wkf-atd-front](../wkf-atd-front/) - Frontend source with `src/environments/` files
