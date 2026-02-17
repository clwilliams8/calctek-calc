# GKE Deployment Runbook

## Prerequisites

Before deploying to GKE, ensure you have:

- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Helm](https://helm.sh/docs/intro/install/) installed
- Docker running locally
- A GCP project with billing enabled
- The `.env` file populated with `GCP_PROJECT_ID`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `APP_KEY`

## One-Command Deployment

The fastest way to deploy everything:

```bash
make gke-deploy-all
```

This runs the following steps in sequence:

1. `gke-init` -- Authenticate with GCP, enable APIs, configure Docker auth
2. `gke-cluster` -- Create a GKE Standard cluster (~5 minutes)
3. `gke-registry` -- Create an Artifact Registry repository
4. `gke-creds` -- Configure kubectl with cluster credentials
5. `gke-ingress` -- Install Nginx Ingress Controller and cert-manager via Helm
6. `gke-build` -- Build production Docker images for backend, frontend, and docs
7. `gke-push` -- Push images to Artifact Registry
8. `gke-deploy` -- Apply Kubernetes manifests, create secrets and configmaps

After completion, the live URLs are printed automatically.

---

## Step-by-Step Deployment

If you need to run steps individually (e.g., for debugging or partial re-deployment):

### 1. Initialize GCP

```bash
make gke-init
```

Authenticates with `gcloud`, sets the project, enables the Container and Artifact Registry APIs, and configures Docker to push to the regional registry.

### 2. Create Cluster

```bash
make gke-cluster
```

Creates a single-node `e2-medium` GKE Standard cluster in `us-central1-a`. Takes approximately 5 minutes.

### 3. Create Registry

```bash
make gke-registry
```

Creates the `calctek-calc` Artifact Registry repository for Docker images.

### 4. Get Credentials

```bash
make gke-creds
```

Configures `kubectl` to communicate with the newly created cluster.

### 5. Install Ingress

```bash
make gke-ingress
```

Installs Nginx Ingress Controller and cert-manager via Helm. The Ingress Controller provisions a GCP LoadBalancer with an external IP.

### 6. Build Images

```bash
make gke-build
```

Builds `linux/amd64` production images for all three services. The frontend build bakes in the `VITE_API_URL` based on the current LoadBalancer IP.

### 7. Push Images

```bash
make gke-push
```

Pushes all three images to Artifact Registry.

### 8. Deploy

```bash
make gke-deploy
```

Applies all Kubernetes manifests:

- Creates namespace, secrets, and configmap
- Deploys backend (with PVC for SQLite), frontend, and docs
- Creates ClusterIP services
- Configures Ingress with host-based routing using sslip.io

---

## Post-Deployment Verification

### Check Status

```bash
make gke-status
```

Expected output: all pods in `Running` state, services with ClusterIP, ingress with assigned address.

### Get URLs

```bash
make gke-urls
```

Prints the live sslip.io URLs for frontend, API, docs, and health check.

### Health Check

```bash
make gke-health
```

Calls the backend `/health` endpoint through the Ingress.

### View Logs

```bash
make gke-logs
```

Tails logs from all pods in the `calctek-calc` namespace.

---

## Troubleshooting

### Pods stuck in `Pending`

```bash
kubectl describe pod -n calctek-calc <pod-name>
```

Common causes:

- **Insufficient resources**: The `e2-medium` node has limited CPU/memory. Check `kubectl describe node`.
- **PVC not bound**: Ensure the PVC is bound with `kubectl get pvc -n calctek-calc`.
- **Image pull errors**: Verify `gcloud auth configure-docker` was run and images are pushed.

### Pods in `CrashLoopBackOff`

```bash
kubectl logs -n calctek-calc <pod-name> --previous
```

Common causes:

- **Missing secrets**: Verify secrets exist with `kubectl get secrets -n calctek-calc`.
- **Missing configmap**: Verify configmap exists with `kubectl get configmap -n calctek-calc`.
- **Database migration needed**: Shell into the backend pod and run migrations.

### No LoadBalancer IP

```bash
kubectl get svc -n ingress-nginx
```

If `EXTERNAL-IP` shows `<pending>` for more than 5 minutes:

- Ensure the GCP project has billing enabled.
- Check GCP quotas for external IP addresses.
- Verify the Ingress Controller pod is running: `kubectl get pods -n ingress-nginx`.

### Frontend shows blank page or API errors

- Verify `VITE_API_URL` was baked correctly during build: `make gke-build` reads the LB IP.
- If the IP changed, rebuild and redeploy the frontend: `make gke-build && make gke-push && make gke-deploy`.
- Check CORS and `FRONTEND_URL` in the backend configmap.

### Database issues

SQLite runs on a PVC. If data is lost:

- Verify PVC is bound: `kubectl get pvc -n calctek-calc`.
- Shell into the backend pod: `kubectl exec -it -n calctek-calc <backend-pod> -- bash`.
- Run migrations: `php artisan migrate`.

---

## Re-deployment (Code Changes)

To deploy updated code without recreating the cluster:

```bash
make gke-build     # Rebuild images
make gke-push      # Push to registry
make gke-deploy    # Re-apply manifests (triggers rolling update)
```

---

## Teardown

To destroy all GKE resources (cluster and registry):

```bash
make gke-destroy
```

!!! warning
    This permanently deletes the GKE cluster, all pods, services, persistent volumes, and the Artifact Registry repository. This action cannot be undone.

You will be prompted to confirm before destruction proceeds.
