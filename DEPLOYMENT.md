# CalcTek Calculator - Production Deployment

## Live URLs

| Service | URL |
|---------|-----|
| **Frontend (App)** | http://app.34-27-81-95.sslip.io |
| **Backend API** | http://api.34-27-81-95.sslip.io |
| **API Health Check** | http://api.34-27-81-95.sslip.io/health |
| **GraphQL Endpoint** | http://api.34-27-81-95.sslip.io/graphql |
| **Documentation** | http://docs.34-27-81-95.sslip.io |

## GCP Infrastructure

| Resource | Value |
|----------|-------|
| GCP Project | `calculator-demo-487717` |
| Region / Zone | `us-central1` / `us-central1-a` |
| GKE Cluster | `calctek-calc-cluster` |
| Machine Type | `e2-medium` (1 node) |
| Artifact Registry | `us-central1-docker.pkg.dev/calculator-demo-487717/calctek-calc` |
| K8s Namespace | `calctek-calc` |
| LoadBalancer IP | `34.27.81.95` |

## Google OAuth Setup

To enable Google Sign-In on the production deployment, add this **Authorized redirect URI** in [Google Cloud Console > APIs & Credentials > OAuth 2.0 Client](https://console.cloud.google.com/apis/credentials):

```
http://api.34-27-81-95.sslip.io/auth/google/callback
```

Also add the frontend origin as an **Authorized JavaScript origin**:

```
http://app.34-27-81-95.sslip.io
```

## Common Operations

```bash
# Check pod status
make gke-status

# Check backend health
make gke-health

# View live URLs
make gke-urls

# Get LoadBalancer IP
make gke-ip

# Tail all pod logs
make gke-logs

# Rebuild and redeploy (after code changes)
make gke-build && make gke-push && make gke-deploy

# Full teardown (deletes cluster + registry)
make gke-destroy
```

## Architecture

- **Backend**: Laravel 12 + Lighthouse GraphQL, PHP-FPM behind Nginx sidecar
- **Frontend**: Vue 3 + Vite, static build served by Nginx
- **Database**: SQLite on a PersistentVolumeClaim (1Gi)
- **Docs**: MkDocs Material
- **Ingress**: Nginx Ingress Controller with sslip.io DNS
- **Secrets**: K8s Secret (`calctek-calc-secrets`) for APP_KEY, Google OAuth credentials
- **Config**: K8s ConfigMap (`calctek-calc-config`) for dynamic URLs + Nginx config
