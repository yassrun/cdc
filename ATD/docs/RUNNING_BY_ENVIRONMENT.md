# Running ATD Application by Environment

This guide explains how to build and run the ATD application in different environments: **local**, **dev**, **staging**, and **prod**.

## Quick Reference

| Environment | Command | Services | Database | Keycloak |
|---|---|---|---|---|
| **local** | `./run-local.sh --env local deploy-local` | Docker | Docker (localhost:5432) | Docker (localhost:8080) |
| **dev** | `./run-local.sh --env dev build-all` | Manual | postgres-dev.sgmaroc.root.net | sso-dev.sgmaroc.root.net |
| **staging** | `./run-local.sh --env staging build-all` | Manual | postgres-staging.sgmaroc.root.net | sso-staging.sgmaroc.root.net |
| **prod** | `./run-local.sh --env prod build-all` | Manual | postgres-prod.sgmaroc.root.net | sso.sgmaroc.root.net |

---

## LOCAL Environment (Development Machine)

### Overview
- **Location**: Your local machine
- **BFF URL**: http://localhost:9090/api
- **Frontend URL**: http://localhost:4200
- **Database**: PostgreSQL in Docker (localhost:5432)
- **Keycloak**: Docker (localhost:8080)
- **Use Case**: Full local development with all services

### Prerequisites
- Docker Desktop running
- Node.js v20.19.0 (in tools folder)
- JDK 17.0.18 (in tools folder)
- Bash or PowerShell terminal
- CNTLM proxy running (if on corporate network)

### Step-by-step

**1. Load environment variables**:
```bash
# From project root
source ./env/load-env.sh local
```

**2. Start everything** (builds + services):
```bash
./run-local.sh deploy-local
```

This will:
- Start PostgreSQL container (waits for health check)
- Start Keycloak container (waits for health check)
- Build BFF (Maven clean package)
- Build Frontend (npm install + ng build)
- Start BFF on :9090
- Start Frontend on :4200

**3. Access applications**:
- **Frontend**: http://localhost:4200
- **BFF API**: http://localhost:9090/api
- **Keycloak Admin**: http://localhost:8080 (admin/admin123)
- **PostgreSQL**: localhost:5432 (postgres/postgres)

**4. Stop all services**:
```bash
# Press Ctrl+C to stop BFF and Frontend
# Then stop Docker containers:
./run-local.sh down-db
```

### Build Only (without running)
```bash
./run-local.sh --env local build-all
```

### Start Services (after previous build)
```bash
./run-local.sh --env local up
```

---

## DEV Environment (Development Server)

### Overview
- **Location**: Corporate development servers
- **BFF**: Development deployment server
- **Database**: postgres-dev.sgmaroc.root.net
- **Keycloak**: sso-dev.sgmaroc.root.net (corporate)
- **External APIs**: Recette environment (apirecette.sgmaroc.root.net)
- **Use Case**: Testing with real(ish) infrastructure and services

### Prerequisites
- Access to development servers
- Credentials for dev Keycloak and database
- VPN access (if required)
- CNTLM proxy configured

### Step-by-step

**1. Load dev environment**:
```bash
source ./env/load-env.sh dev
```

**2. Verify configuration** (optional):
```bash
echo "Database: $DB_HOST:$DB_PORT"
echo "Keycloak: $KEYCLOAK_URL"
echo "GED Service: $CORE_API_GED_URL"
```

**3. Build applications**:
```bash
./run-local.sh --env dev build-all
```

This compiles:
- BFF JAR: `wkf-atd-bff/target/workflow-atd-bff-*.jar`
- Frontend: `wkf-atd-front/dist/`

**4. Deploy to dev server** (manual):

**BFF Deployment**:
```bash
# Copy JAR to dev server
scp wkf-atd-bff/target/workflow-atd-bff-*.jar user@dev-server:/opt/wkf-atd/

# SSH into server and run (using systemd or direct):
java -jar /opt/wkf-atd/workflow-atd-bff-*.jar \
  --spring.profiles.active=dev \
  --spring.datasource.url=jdbc:postgresql://postgres-dev.sgmaroc.root.net:5432/workflow_atd_dev
```

**Frontend Deployment**:
```bash
# Copy build artifacts to web server
scp -r wkf-atd-front/dist/* user@web-server:/var/www/wkf-atd/

# Configure nginx (example):
# location /api/ {
#   proxy_pass http://bff-dev:9090;
# }
```

**5. Access applications**:
- **Frontend**: https://wkf-atd-dev.sgmaroc.root.net
- **BFF API**: https://wkf-atd-dev.sgmaroc.root.net/api
- **Keycloak**: https://sso-dev.sgmaroc.root.net/

**6. Troubleshooting**:
```bash
# Check BFF logs
tail -f /var/log/wkf-atd/bff.log

# Check database connectivity
psql -h postgres-dev.sgmaroc.root.net -U atd_dev_user -d workflow_atd_dev -c '\dt'

# Verify Keycloak
curl https://sso-dev.sgmaroc.root.net/health/ready
```

---

## STAGING Environment (Pre-Production)

### Overview
- **Location**: Corporate staging servers
- **BFF**: Staging deployment server
- **Database**: postgres-staging.sgmaroc.root.net
- **Keycloak**: sso-staging.sgmaroc.root.net
- **External APIs**: Staging URLs (apistaging.sgmaroc.root.net)
- **Use Case**: Pre-production testing before production release

### Prerequisites
- Access to staging servers
- Staging Keycloak and database credentials
- VPN access (if required)
- SSL/TLS certificates configured

### Step-by-step

**1. Load staging environment**:
```bash
source ./env/load-env.sh staging
```

**2. Build applications**:
```bash
./run-local.sh --env staging build-all
```

**3. Deploy to staging server**:

Same process as dev, but with staging URLs:

**BFF**:
```bash
java -jar workflow-atd-bff-*.jar \
  --spring.profiles.active=staging \
  --spring.datasource.url=jdbc:postgresql://postgres-staging.sgmaroc.root.net:5432/workflow_atd_staging \
  --server.ssl.enabled=true \
  --server.ssl.key-store=/etc/ssl/certs/keystore.p12
```

**4. Access applications**:
- **Frontend**: https://wkf-atd-staging.sgmaroc.root.net
- **BFF API**: https://wkf-atd-staging.sgmaroc.root.net/api
- **Keycloak**: https://sso-staging.sgmaroc.root.net/

**5. Smoke tests** (verify before promoting to prod):
```bash
# Check frontend loads
curl -I https://wkf-atd-staging.sgmaroc.root.net

# Check API responds
curl https://wkf-atd-staging.sgmaroc.root.net/api/health

# Check Keycloak JWT validation
curl https://sso-staging.sgmaroc.root.net/realms/realm_ce_staging/protocol/openid-connect/certs
```

---

## PROD Environment (Production)

### Overview
- **Location**: Corporate production servers
- **BFF**: Production deployment server
- **Database**: postgres-prod.sgmaroc.root.net
- **Keycloak**: sso.sgmaroc.root.net
- **External APIs**: Production URLs (api.sgmaroc.root.net)
- **Use Case**: Live production environment

⚠️ **CAUTION**: All changes in production should be:
- Code reviewed and merged to master
- Thoroughly tested in staging
- Deployed by authorized personnel only

### Prerequisites
- Production access credentials
- Code approval and audit trail
- Deployment windows documented
- Rollback plan prepared

### Step-by-step

**1. Load prod environment**:
```bash
source ./env/load-env.sh prod
```

**2. Build applications**:
```bash
./run-local.sh --env prod build-all
```

**3. Pre-deployment checklist**:
```bash
# ✓ All tests passing
# ✓ Code reviewed and approved
# ✓ Staging deployment successful
# ✓ Database migrations prepared
# ✓ SSL certificates valid
# ✓ Team notified
# ✓ Rollback plan documented
```

**4. Deploy to production**:

**BFF**:
```bash
# Stop current service
systemctl stop wkf-atd-bff

# Backup old JAR
cp /opt/wkf-atd/workflow-atd-bff.jar /opt/wkf-atd/workflow-atd-bff.jar.backup

# Deploy new JAR
cp workflow-atd-bff-*.jar /opt/wkf-atd/workflow-atd-bff.jar

# Start service
systemctl start wkf-atd-bff

# Monitor logs
journalctl -u wkf-atd-bff -f
```

**Frontend**:
```bash
# Backup old version
tar -czf /var/www/backups/wkf-atd-$(date +%Y%m%d).tar.gz /var/www/wkf-atd/

# Deploy new version
rm -rf /var/www/wkf-atd/*
cp -r dist/* /var/www/wkf-atd/

# Verify nginx config
nginx -t

# Reload nginx
systemctl reload nginx
```

**5. Post-deployment validation**:
```bash
# Check frontend loads
curl -I https://wkf-atd.sgmaroc.root.net

# Check API responses
curl https://wkf-atd.sgmaroc.root.net/api/health

# Check database queries work
curl https://wkf-atd.sgmaroc.root.net/api/users -H "Authorization: Bearer $TOKEN"

# Monitor error logs
tail -f /var/log/wkf-atd/error.log
```

**6. Alerting and Monitoring**:
- Ensure APM/monitoring tools are tracking
- Verify error reporting is active
- Check application metrics (response times, throughput, errors)
- Monitor infrastructure (CPU, memory, disk, network)

**7. Rollback Plan** (if needed):
```bash
# Stop current service
systemctl stop wkf-atd-bff

# Restore previous JAR
cp /opt/wkf-atd/workflow-atd-bff.jar.backup /opt/wkf-atd/workflow-atd-bff.jar

# Restart
systemctl start wkf-atd-bff

# Restore frontend
tar -xzf /var/www/backups/wkf-atd-$(date -d'1 day ago' +%Y%m%d).tar.gz -C /
systemctl reload nginx

# Notify team
# Document incident
```

---

## Environment Configuration Reference

### .env Files Location
```
ATD/env/
├── .env.local     # Local development
├── .env.dev       # Development server
├── .env.staging   # Staging server
├── .env.prod      # Production server
└── .env.example   # Template
```

### Key Variables by Environment

| Variable | Local | Dev | Staging | Prod |
|----------|-------|-----|---------|------|
| `SPRING_PROFILES_ACTIVE` | local | dev | staging | prod |
| `BFF_HOST` | localhost | localhost | wkf-atd-bff-staging.sgmaroc.root.net | wkf-atd-bff.sgmaroc.root.net |
| `BFF_PORT` | 9090 | 9090 | 443 | 443 |
| `FRONT_PORT` | 4200 | 443 | 443 | 443 |
| `DB_HOST` | localhost | postgres-dev.sgmaroc.root.net | postgres-staging.sgmaroc.root.net | postgres-prod.sgmaroc.root.net |
| `KEYCLOAK_HOST` | localhost | sso-dev.sgmaroc.root.net | sso-staging.sgmaroc.root.net | sso.sgmaroc.root.net |

---

## Common Workflows

### Daily Local Development
```bash
source ./env/load-env.sh local
./run-local.sh --env local up  # No build, just start services
```

### Test New Feature Locally
```bash
source ./env/load-env.sh local
./run-local.sh --env local build-all
# Make code changes
./run-local.sh --env local build-back  # Just rebuild BFF
# or refresh browser for frontend hot reload
```

### Prepare Release (local → dev → staging → prod)
```bash
# 1. Test locally
source ./env/load-env.sh local
./run-local.sh --env local deploy-local
# ... verify all features work

# 2. Build for dev
source ./env/load-env.sh dev
./run-local.sh --env dev build-all

# 3. Deploy to dev (manual)
# ... test on dev server

# 4. Build for staging
source ./env/load-env.sh staging
./run-local.sh --env staging build-all

# 5. Deploy to staging (manual)
# ... full testing on staging

# 6. Build for prod
source ./env/load-env.sh prod
./run-local.sh --env prod build-all

# 7. Deploy to prod (manual, with approvals)
```

---

## Troubleshooting

### Services Won't Start
```bash
# Check logs
docker logs wkf-atd-postgres
docker logs wkf-atd-keycloak

# Check port conflicts
lsof -i :9090  # BFF
lsof -i :4200  # Frontend
lsof -i :5432  # PostgreSQL
lsof -i :8080  # Keycloak

# Restart everything
./run-local.sh down-db
./run-local.sh --env local up  # or deploy-local
```

### Cannot Connect to Database
```bash
# Check environment variables loaded
echo $SPRING_DATASOURCE_URL

# Test connection (local)
docker compose -f docker-compose.local.yml exec postgres psql -U postgres -c '\l'

# Check firewall/network (dev/staging/prod)
telnet postgres-dev.sgmaroc.root.net 5432
```

### Keycloak Health Check Fails
```bash
# Check if running
docker ps | grep keycloak

# Check logs
docker logs wkf-atd-keycloak

# Manual health check
curl http://localhost:8080/health/ready

# Wait a bit longer (first startup can take time)
sleep 30 && curl http://localhost:8080/health/ready
```

### Frontend Can't Reach BFF
```bash
# Check BFF is running
curl http://localhost:9090/api/health

# Check proxy configuration
cat wkf-atd-front/proxy.conf.json

# Check browser console for CORS errors
# Open http://localhost:4200 and check Network tab
```

---

## Summary

| Task | Command |
|------|---------|
| **Start local (full)** | `./run-local.sh --env local deploy-local` |
| **Start local (no build)** | `./run-local.sh --env local up` |
| **Stop local** | `./run-local.sh down-db` + Ctrl+C |
| **Build for dev** | `./run-local.sh --env dev build-all` |
| **Build for staging** | `./run-local.sh --env staging build-all` |
| **Build for prod** | `./run-local.sh --env prod build-all` |
| **Load variables** | `source ./env/load-env.sh <env>` |

---

## Support

For issues or questions:
1. Check [ENV_INTEGRATION_GUIDE.md](ENV_INTEGRATION_GUIDE.md) for technical details
2. Review [Troubleshooting](#troubleshooting) section above
3. Check logs in `wkf-atd-bff/logs/` or Docker logs
4. Contact the development team
