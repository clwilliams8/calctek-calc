# Include environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
else
    # If .env doesn't exist, create it from example
    $(shell if [ -f .env.example ]; then cp .env.example .env && chown $(shell whoami):$(shell id -gn) .env; fi)
    include .env
    export
endif

# Default variables (fallbacks if .env is missing)
PROJECT ?= calctek-calc
PROJECT_TITLE ?= "CalcTek Calculator"
NETWORK_NAME ?= calctek-calc-network
DOMAIN_NAME ?= dev.calctek-calc.ai
HOSTS_SUBDOMAINS ?= api,app,docs
LOCAL_IP ?= 192.168.204.5

# Generate sanitized project name for launchdaemon (lowercase, no spaces)
SANITIZED_PROJECT_NAME = $(shell echo $(PROJECT) | tr '[:upper:]' '[:lower:]' | tr ' -' '_')

# For string manipulation
comma := ,
space :=
space +=

# Check for root/sudo
ifeq ($(shell id -u),0)
    SUDO :=
else
    SUDO := sudo
endif

# Colors and formatting
BLUE := $(shell tput setaf 4)
CYAN := $(shell tput setaf 6)
GREEN := $(shell tput setaf 2)
RED := $(shell tput setaf 1)
YELLOW := $(shell tput setaf 3)
WHITE := $(shell tput setaf 7)
BOLD := $(shell tput bold)
NC := $(shell tput sgr0)
DIVIDER := $(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)

.PHONY: start stop check help hosts ssl launchdaemon env docker network clean config setup logs logs-be logs-fe logs-docs logs-nginx restart status build build-be build-fe shell-be shell-fe health migrate tinker \
	gke-init gke-cluster gke-registry gke-build gke-push gke-creds gke-ingress gke-deploy gke-ip gke-urls gke-status gke-logs gke-destroy gke-deploy-all gke-health gke-help

setup: check hosts ssl network launchdaemon config
	@echo "$(GREEN)Setup complete!$(NC)"
	@echo "$(YELLOW)Now run 'make start' to start the containers$(NC)"

start:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Starting Docker containers...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)Containers started!$(NC)"
	@echo ""
	@echo "$(BOLD)URLs:$(NC)"
	@echo "  $(CYAN)Frontend:$(NC)  https://app.$(DOMAIN_NAME)"
	@echo "  $(CYAN)API:$(NC)       https://api.$(DOMAIN_NAME)"
	@echo "  $(CYAN)Docs:$(NC)      https://docs.$(DOMAIN_NAME)"

stop:
	@echo "$(GREEN)Stopping Docker containers...$(NC)"
	@docker-compose down
	@echo "$(GREEN)Containers stopped!$(NC)"

restart:
	@echo "$(CYAN)Restarting Docker containers...$(NC)"
	@docker-compose down
	@docker-compose up -d
	@echo "$(GREEN)Containers restarted!$(NC)"

logs:
	@docker-compose logs -f

logs-be:
	@docker-compose logs -f backend

logs-fe:
	@docker-compose logs -f frontend

logs-docs:
	@docker-compose logs -f docs

logs-nginx:
	@docker-compose logs -f nginx

status:
	@docker-compose ps

build:
	@echo "$(CYAN)Rebuilding all containers...$(NC)"
	@docker-compose up -d --build
	@echo "$(GREEN)All containers rebuilt!$(NC)"

build-be:
	@echo "$(CYAN)Rebuilding backend container...$(NC)"
	@docker-compose up -d --build backend
	@echo "$(GREEN)Backend rebuilt!$(NC)"

build-fe:
	@echo "$(CYAN)Rebuilding frontend container...$(NC)"
	@docker-compose up -d --build frontend
	@echo "$(GREEN)Frontend rebuilt!$(NC)"

shell-be:
	@docker-compose exec backend bash

shell-fe:
	@docker-compose exec frontend sh

health:
	@echo "$(CYAN)Checking backend health...$(NC)"
	@curl -sk https://api.$(DOMAIN_NAME)/health | python3 -m json.tool 2>/dev/null || \
		curl -sk https://api.$(DOMAIN_NAME)/health 2>/dev/null || \
		echo "$(RED)Backend not responding$(NC)"

migrate:
	@echo "$(CYAN)Running database migrations...$(NC)"
	@docker-compose exec backend php artisan migrate
	@echo "$(GREEN)Migrations complete!$(NC)"

tinker:
	@docker-compose exec backend php artisan tinker

# Help (local dev + GKE)
help:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Usage: sudo make [command]$(NC)"
	@echo "$(DIVIDER)"
	@echo "$(BOLD)Docker:$(NC)"
	@echo "  $(YELLOW)start$(NC)         - $(WHITE)Start Docker containers$(NC)"
	@echo "  $(YELLOW)stop$(NC)          - $(WHITE)Stop Docker containers$(NC)"
	@echo "  $(YELLOW)restart$(NC)       - $(WHITE)Restart Docker containers$(NC)"
	@echo "  $(YELLOW)status$(NC)        - $(WHITE)Show container status$(NC)"
	@echo "  $(YELLOW)build$(NC)         - $(WHITE)Rebuild all containers$(NC)"
	@echo "  $(YELLOW)build-be$(NC)      - $(WHITE)Rebuild backend only$(NC)"
	@echo "  $(YELLOW)build-fe$(NC)      - $(WHITE)Rebuild frontend only$(NC)"
	@echo "  $(YELLOW)shell-be$(NC)      - $(WHITE)Shell into backend container$(NC)"
	@echo "  $(YELLOW)shell-fe$(NC)      - $(WHITE)Shell into frontend container$(NC)"
	@echo "  $(YELLOW)health$(NC)        - $(WHITE)Check backend health endpoint$(NC)"
	@echo ""
	@echo "$(BOLD)Laravel:$(NC)"
	@echo "  $(YELLOW)migrate$(NC)       - $(WHITE)Run database migrations$(NC)"
	@echo "  $(YELLOW)tinker$(NC)        - $(WHITE)Open Laravel Tinker REPL$(NC)"
	@echo ""
	@echo "$(BOLD)Logs:$(NC)"
	@echo "  $(YELLOW)logs$(NC)          - $(WHITE)Follow all container logs$(NC)"
	@echo "  $(YELLOW)logs-be$(NC)       - $(WHITE)Follow backend logs$(NC)"
	@echo "  $(YELLOW)logs-fe$(NC)       - $(WHITE)Follow frontend logs$(NC)"
	@echo "  $(YELLOW)logs-docs$(NC)     - $(WHITE)Follow docs logs$(NC)"
	@echo "  $(YELLOW)logs-nginx$(NC)    - $(WHITE)Follow nginx logs$(NC)"
	@echo ""
	@echo "$(BOLD)Setup:$(NC)"
	@echo "  $(YELLOW)setup$(NC)         - $(WHITE)Run complete setup (hosts, ssl, network, launchdaemon)$(NC)"
	@echo "  $(YELLOW)check$(NC)         - $(WHITE)Verify prerequisites$(NC)"
	@echo "  $(YELLOW)hosts$(NC)         - $(WHITE)Setup hosts file$(NC)"
	@echo "  $(YELLOW)ssl$(NC)           - $(WHITE)Generate SSL certificates$(NC)"
	@echo "  $(YELLOW)launchdaemon$(NC)  - $(WHITE)Setup launch daemon (macOS)$(NC)"
	@echo "  $(YELLOW)network$(NC)       - $(WHITE)Create Docker networks$(NC)"
	@echo "  $(YELLOW)config$(NC)        - $(WHITE)Display current configuration$(NC)"
	@echo "  $(YELLOW)clean$(NC)         - $(WHITE)Remove setup files$(NC)"
	@echo ""
	@echo "$(BOLD)GKE Production:$(NC)"
	@echo "  $(YELLOW)gke-deploy-all$(NC) - $(WHITE)One-command full deployment to GKE$(NC)"
	@echo "  $(YELLOW)gke-init$(NC)      - $(WHITE)Authenticate and enable GCP APIs$(NC)"
	@echo "  $(YELLOW)gke-cluster$(NC)   - $(WHITE)Create GKE cluster$(NC)"
	@echo "  $(YELLOW)gke-registry$(NC)  - $(WHITE)Create Artifact Registry repo$(NC)"
	@echo "  $(YELLOW)gke-build$(NC)     - $(WHITE)Build production Docker images$(NC)"
	@echo "  $(YELLOW)gke-push$(NC)      - $(WHITE)Push images to Artifact Registry$(NC)"
	@echo "  $(YELLOW)gke-creds$(NC)     - $(WHITE)Get kubectl credentials$(NC)"
	@echo "  $(YELLOW)gke-ingress$(NC)   - $(WHITE)Install Nginx Ingress + cert-manager$(NC)"
	@echo "  $(YELLOW)gke-deploy$(NC)    - $(WHITE)Apply k8s manifests$(NC)"
	@echo "  $(YELLOW)gke-ip$(NC)        - $(WHITE)Get LoadBalancer external IP$(NC)"
	@echo "  $(YELLOW)gke-urls$(NC)      - $(WHITE)Print live sslip.io URLs$(NC)"
	@echo "  $(YELLOW)gke-status$(NC)    - $(WHITE)Show GKE pod/service status$(NC)"
	@echo "  $(YELLOW)gke-logs$(NC)      - $(WHITE)Tail GKE pod logs$(NC)"
	@echo "  $(YELLOW)gke-health$(NC)    - $(WHITE)Check GKE backend health$(NC)"
	@echo "  $(YELLOW)gke-destroy$(NC)   - $(WHITE)Full teardown (cluster + registry)$(NC)"
	@echo "$(DIVIDER)"

# Print current configuration
config:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Current Configuration:$(NC)"
	@echo "$(DIVIDER)"
	@echo "$(BOLD)Project:$(NC)      $(PROJECT)"
	@echo "$(BOLD)Title:$(NC)        $(PROJECT_TITLE)"
	@echo "$(BOLD)Network:$(NC)      $(NETWORK_NAME)"
	@echo "$(BOLD)Domain:$(NC)       $(DOMAIN_NAME)"
	@echo "$(BOLD)Subdomains:$(NC)   $(HOSTS_SUBDOMAINS)"
	@echo "$(BOLD)Local IP:$(NC)     $(LOCAL_IP)"
	@echo "$(DIVIDER)"

# Check prerequisites
check:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Checking prerequisites...$(NC)"
	@which docker >/dev/null 2>&1 || (echo "$(RED)Docker not installed$(NC)" && exit 1)
	@echo "$(GREEN)Docker is installed.$(NC)"
	@which docker-compose >/dev/null 2>&1 || (echo "$(RED)docker-compose not installed$(NC)" && exit 1)
	@echo "$(GREEN)docker-compose is installed.$(NC)"
	@which mkcert >/dev/null 2>&1 || (echo "$(RED)mkcert not installed$(NC)" && exit 1)
	@echo "$(GREEN)mkcert is installed.$(NC)"
	@which pnpm >/dev/null 2>&1 || (echo "$(RED)pnpm not installed$(NC)" && exit 1)
	@echo "$(GREEN)pnpm is installed.$(NC)"

# Hosts file setup
hosts:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Setting up hosts file...$(NC)"
	@if grep -qF $(PROJECT_TITLE) /etc/hosts; then \
		echo "$(GREEN)Hosts file already setup.$(NC)"; \
	else \
		echo "\n# $(PROJECT_TITLE)" | $(SUDO) tee -a /etc/hosts > /dev/null; \
		echo "$(LOCAL_IP) $(foreach sub,$(subst $(comma),$(space),$(HOSTS_SUBDOMAINS)),$(sub).$(DOMAIN_NAME))" | $(SUDO) tee -a /etc/hosts > /dev/null; \
		echo "$(GREEN)Hosts file entries generated.$(NC)"; \
	fi

# SSL certificate setup
ssl:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Setting up local HTTPS...$(NC)"
	@mkdir -p ./docker/ssl
	@$(SUDO) chown $(shell whoami):$(shell id -gn) ./docker/ssl
	@if [ "$(SUDO)" != "" ]; then \
		current_user=$(shell whoami); \
		$(SUDO) -u $$current_user bash -c "mkcert -key-file ./docker/ssl/mkcert.key -cert-file ./docker/ssl/mkcert.pem \"*.$(DOMAIN_NAME)\" >/dev/null 2>&1"; \
		$(SUDO) -u $$current_user bash -c "caroot=\"$$(mkcert -CAROOT)\" && cp \"$$(mkcert -CAROOT)/rootCA.pem\" ./docker/ssl/"; \
	else \
		mkcert -key-file ./docker/ssl/mkcert.key -cert-file ./docker/ssl/mkcert.pem "*.$(DOMAIN_NAME)" >/dev/null 2>&1; \
		caroot=$$(mkcert -CAROOT) && cp "$$caroot/rootCA.pem" ./docker/ssl/; \
	fi
	@$(SUDO) chown $(shell whoami):$(shell id -gn) ./docker/ssl/*
	@$(SUDO) chmod 644 ./docker/ssl/*.key ./docker/ssl/*.pem
	@echo "$(GREEN)Local HTTPS generated with proper permissions.$(NC)"

# Launch daemon setup (macOS specific)
launchdaemon:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Checking Launch Daemons...$(NC)"
	@if ifconfig | grep -q "inet $(LOCAL_IP)"; then \
		files=$$(grep "$(LOCAL_IP)" /Library/LaunchDaemons/** | awk '{print $$1}' | sed s/\://g); \
		if echo "$$files" | grep -q "$(SANITIZED_PROJECT_NAME)"; then \
			echo "$(GREEN)Launch Daemon already setup.$(NC)"; \
		else \
			echo "$(RED)IP Address already allocated by: $$files$(NC)"; \
			exit 1; \
		fi \
	else \
		sed -e 's/%IP_ADDRESS%/$(LOCAL_IP)/g' \
			-e 's/%PROJECT%/$(PROJECT)/g' \
			docker/setup/com.localdev.project.plist \
			| $(SUDO) tee "/Library/LaunchDaemons/com.localdev.$(SANITIZED_PROJECT_NAME).plist" > /dev/null; \
		$(SUDO) launchctl load "/Library/LaunchDaemons/com.localdev.$(SANITIZED_PROJECT_NAME).plist"; \
		echo "$(GREEN)Launch Daemons setup.$(NC)"; \
	fi

# Docker network setup
network:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Creating Docker Network...$(NC)"
	@docker network create $(NETWORK_NAME) >/dev/null 2>&1 || true
	@echo "$(GREEN)Docker network created.$(NC)"

# Cleanup
clean:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Cleaning up...$(NC)"
	@$(SUDO) rm -rf ./docker/ssl
	@$(SUDO) sed -i.bak '/$(PROJECT_TITLE)/d' /etc/hosts
	@$(SUDO) sed -i.bak '/$(LOCAL_IP)/d' /etc/hosts
	@$(SUDO) rm -f "/Library/LaunchDaemons/com.localdev.$(SANITIZED_PROJECT_NAME).plist"
	@docker network rm $(NETWORK_NAME) 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete.$(NC)"

###################################################################
# GKE Production Deployment
###################################################################

# GKE default variables
GCP_PROJECT_ID ?= $(shell echo $$GCP_PROJECT_ID)
GCP_REGION ?= us-central1
GCP_ZONE ?= us-central1-a
GKE_CLUSTER_NAME ?= calctek-calc-cluster
GKE_MACHINE_TYPE ?= e2-medium
GKE_NUM_NODES ?= 1
AR_REPO_NAME ?= calctek-calc

# Derived GKE variables
AR_HOSTNAME = $(GCP_REGION)-docker.pkg.dev
AR_REGISTRY = $(AR_HOSTNAME)/$(GCP_PROJECT_ID)/$(AR_REPO_NAME)
K8S_NAMESPACE = calctek-calc

# Authenticate and enable GCP APIs
gke-init:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Initializing Google Cloud...$(NC)"
	@gcloud auth login --no-launch-browser 2>/dev/null || gcloud auth login
	@gcloud config set project $(GCP_PROJECT_ID)
	@echo "$(CYAN)Enabling required APIs...$(NC)"
	@gcloud services enable container.googleapis.com artifactregistry.googleapis.com
	@gcloud auth configure-docker $(AR_HOSTNAME) --quiet
	@echo "$(GREEN)GCP initialized. Project: $(GCP_PROJECT_ID)$(NC)"

# Create GKE Standard cluster
gke-cluster:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Creating GKE cluster '$(GKE_CLUSTER_NAME)'...$(NC)"
	@echo "$(YELLOW)This takes ~5 minutes...$(NC)"
	@gcloud container clusters create $(GKE_CLUSTER_NAME) \
		--zone $(GCP_ZONE) \
		--machine-type $(GKE_MACHINE_TYPE) \
		--num-nodes $(GKE_NUM_NODES) \
		--disk-size 30 \
		--enable-ip-alias \
		--no-enable-autoupgrade \
		--no-enable-autorepair
	@echo "$(GREEN)Cluster '$(GKE_CLUSTER_NAME)' created!$(NC)"

# Create Artifact Registry repository
gke-registry:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Creating Artifact Registry repo '$(AR_REPO_NAME)'...$(NC)"
	@gcloud artifacts repositories create $(AR_REPO_NAME) \
		--repository-format=docker \
		--location=$(GCP_REGION) \
		--description="CalcTek Calculator container images" 2>/dev/null || \
		echo "$(YELLOW)Registry already exists.$(NC)"
	@echo "$(GREEN)Artifact Registry ready.$(NC)"

# Build all production Docker images
gke-build:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Building production Docker images...$(NC)"
	@echo "$(YELLOW)Building backend (Laravel PHP-FPM)...$(NC)"
	@docker build --platform linux/amd64 \
		-t $(AR_REGISTRY)/backend:latest \
		-f docker/laravel/Dockerfile .
	@echo "$(YELLOW)Building frontend (Vue.js)...$(NC)"
	@LB_IP=$$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
		-o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -n "$$LB_IP" ]; then \
		SSLIP_IP=$$(echo $$LB_IP | tr '.' '-'); \
		API_URL="https://api.$$SSLIP_IP.sslip.io"; \
		echo "$(CYAN)Baking VITE_API_URL=$$API_URL into frontend build$(NC)"; \
	else \
		API_URL=""; \
		echo "$(YELLOW)No LB IP found — frontend will use default API URL$(NC)"; \
	fi; \
	docker build --platform linux/amd64 \
		-t $(AR_REGISTRY)/frontend:latest \
		--target production \
		--build-arg VITE_API_URL=$$API_URL \
		-f frontend/Dockerfile frontend/
	@echo "$(YELLOW)Building docs (MkDocs)...$(NC)"
	@docker build --platform linux/amd64 \
		-t $(AR_REGISTRY)/docs:latest \
		-f docker/docs/Dockerfile .
	@echo "$(GREEN)All images built!$(NC)"

# Push images to Artifact Registry
gke-push:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Pushing images to Artifact Registry...$(NC)"
	@docker push $(AR_REGISTRY)/backend:latest
	@docker push $(AR_REGISTRY)/frontend:latest
	@docker push $(AR_REGISTRY)/docs:latest
	@echo "$(GREEN)All images pushed!$(NC)"

# Get kubectl credentials for the cluster
gke-creds:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Getting cluster credentials...$(NC)"
	@gcloud container clusters get-credentials $(GKE_CLUSTER_NAME) --zone $(GCP_ZONE)
	@echo "$(GREEN)kubectl configured for $(GKE_CLUSTER_NAME).$(NC)"

# Install Nginx Ingress Controller and cert-manager via Helm
gke-ingress:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Installing Nginx Ingress Controller...$(NC)"
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
	@helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
	@helm repo update
	@helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		--namespace ingress-nginx --create-namespace \
		--set controller.service.type=LoadBalancer \
		--wait
	@echo "$(CYAN)Installing cert-manager...$(NC)"
	@helm upgrade --install cert-manager jetstack/cert-manager \
		--namespace cert-manager --create-namespace \
		--set crds.enabled=true \
		--wait
	@echo "$(GREEN)Ingress and cert-manager installed!$(NC)"

# Apply k8s manifests and create secrets
gke-deploy:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)Deploying to GKE...$(NC)"
	@kubectl apply -f k8s/namespace.yaml
	@kubectl apply -f k8s/cert-issuer.yaml
	@kubectl apply -f k8s/backend-pvc.yaml
	@echo "$(CYAN)Creating secrets from .env...$(NC)"
	@kubectl create secret generic calctek-calc-secrets \
		--namespace $(K8S_NAMESPACE) \
		--from-literal=APP_KEY=$(APP_KEY) \
		--from-literal=GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		--from-literal=GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		--dry-run=client -o yaml | kubectl apply -f -
	@echo "$(CYAN)Waiting for LoadBalancer IP...$(NC)"
	@LB_IP=""; \
	for i in $$(seq 1 60); do \
		LB_IP=$$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
		if [ -n "$$LB_IP" ]; then break; fi; \
		echo "  Waiting for IP... ($$i/60)"; \
		sleep 5; \
	done; \
	if [ -z "$$LB_IP" ]; then \
		echo "$(RED)Timed out waiting for LoadBalancer IP$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)LoadBalancer IP: $$LB_IP$(NC)"; \
	SSLIP_IP=$$(echo $$LB_IP | tr '.' '-'); \
	APP_HOST="app.$$SSLIP_IP.sslip.io"; \
	API_HOST="api.$$SSLIP_IP.sslip.io"; \
	DOCS_HOST="docs.$$SSLIP_IP.sslip.io"; \
	API_URL="https://$$API_HOST"; \
	FRONTEND_URL="https://$$APP_HOST"; \
	echo "$(CYAN)Updating ConfigMap with API URL: $$API_URL$(NC)"; \
	kubectl create configmap calctek-calc-config \
		--namespace $(K8S_NAMESPACE) \
		--from-literal=APP_URL=$$API_URL \
		--from-literal=FRONTEND_URL=$$FRONTEND_URL \
		--from-literal=VITE_API_URL=$$API_URL \
		--from-literal=GOOGLE_REDIRECT_URI=$$API_URL/auth/google/callback \
		--from-file=nginx-k8s.conf=docker/nginx/nginx-k8s.conf \
		--dry-run=client -o yaml | kubectl apply -f -; \
	echo "$(CYAN)Updating image references in manifests...$(NC)"; \
	cat k8s/backend-deployment.yaml | \
		sed "s|BACKEND_IMAGE_PLACEHOLDER|$(AR_REGISTRY)/backend:latest|g" | \
		kubectl apply -f -; \
	cat k8s/frontend-deployment.yaml | \
		sed "s|FRONTEND_IMAGE_PLACEHOLDER|$(AR_REGISTRY)/frontend:latest|g" | \
		kubectl apply -f -; \
	cat k8s/docs-deployment.yaml | \
		sed "s|DOCS_IMAGE_PLACEHOLDER|$(AR_REGISTRY)/docs:latest|g" | \
		kubectl apply -f -; \
	kubectl apply -f k8s/backend-service.yaml; \
	kubectl apply -f k8s/frontend-service.yaml; \
	kubectl apply -f k8s/docs-service.yaml; \
	cat k8s/ingress.yaml | \
		sed "s|APP_HOST_PLACEHOLDER|$$APP_HOST|g" | \
		sed "s|API_HOST_PLACEHOLDER|$$API_HOST|g" | \
		sed "s|DOCS_HOST_PLACEHOLDER|$$DOCS_HOST|g" | \
		kubectl apply -f -; \
	echo "$(GREEN)Deployment complete!$(NC)"; \
	echo ""; \
	echo "$(BOLD)Live URLs:$(NC)"; \
	echo "  $(CYAN)Frontend:$(NC)  https://$$APP_HOST"; \
	echo "  $(CYAN)API:$(NC)       https://$$API_HOST"; \
	echo "  $(CYAN)Docs:$(NC)      https://$$DOCS_HOST"

# Get the LoadBalancer external IP
gke-ip:
	@kubectl get svc -n ingress-nginx ingress-nginx-controller \
		-o jsonpath='{.status.loadBalancer.ingress[0].ip}' && echo ""

# Print the live sslip.io URLs
gke-urls:
	@LB_IP=$$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
		-o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -z "$$LB_IP" ]; then \
		echo "$(RED)No LoadBalancer IP found. Is the cluster running?$(NC)"; \
		exit 1; \
	fi; \
	SSLIP_IP=$$(echo $$LB_IP | tr '.' '-'); \
	echo "$(DIVIDER)"; \
	echo "$(BOLD)Live URLs (IP: $$LB_IP):$(NC)"; \
	echo "$(DIVIDER)"; \
	echo "  $(CYAN)Frontend:$(NC)  https://app.$$SSLIP_IP.sslip.io"; \
	echo "  $(CYAN)API:$(NC)       https://api.$$SSLIP_IP.sslip.io"; \
	echo "  $(CYAN)Docs:$(NC)      https://docs.$$SSLIP_IP.sslip.io"; \
	echo "  $(CYAN)Health:$(NC)    https://api.$$SSLIP_IP.sslip.io/health"; \
	echo "$(DIVIDER)"

# Show GKE resource status
gke-status:
	@echo "$(DIVIDER)"
	@echo "$(CYAN)GKE Status:$(NC)"
	@echo "$(DIVIDER)"
	@kubectl get pods,svc,ingress -n $(K8S_NAMESPACE) 2>/dev/null || \
		echo "$(RED)Cannot connect to cluster. Run 'make gke-creds' first.$(NC)"

# Tail GKE pod logs
gke-logs:
	@echo "$(CYAN)Tailing all pod logs in $(K8S_NAMESPACE)...$(NC)"
	@kubectl logs -n $(K8S_NAMESPACE) --all-containers -l 'app in (backend,frontend,docs)' -f --prefix 2>/dev/null || \
		echo "$(RED)No pods found. Is the app deployed?$(NC)"

# Check GKE backend health
gke-health:
	@LB_IP=$$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
		-o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -z "$$LB_IP" ]; then \
		echo "$(RED)No LoadBalancer IP found.$(NC)"; \
		exit 1; \
	fi; \
	SSLIP_IP=$$(echo $$LB_IP | tr '.' '-'); \
	echo "$(CYAN)Checking GKE backend health...$(NC)"; \
	curl -sk "https://api.$$SSLIP_IP.sslip.io/health" | python3 -m json.tool 2>/dev/null || \
		echo "$(RED)Backend not responding$(NC)"

# Full teardown — delete cluster and registry
gke-destroy:
	@echo "$(DIVIDER)"
	@echo "$(RED)$(BOLD)WARNING: This will delete the GKE cluster and all resources!$(NC)"
	@echo "$(DIVIDER)"
	@read -p "Are you sure? (y/N) " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(CYAN)Deleting GKE cluster...$(NC)"; \
		gcloud container clusters delete $(GKE_CLUSTER_NAME) \
			--zone $(GCP_ZONE) --quiet 2>/dev/null || true; \
		echo "$(CYAN)Deleting Artifact Registry...$(NC)"; \
		gcloud artifacts repositories delete $(AR_REPO_NAME) \
			--location=$(GCP_REGION) --quiet 2>/dev/null || true; \
		echo "$(GREEN)Teardown complete.$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled.$(NC)"; \
	fi

# One-command full deployment
gke-deploy-all: gke-init gke-cluster gke-registry gke-creds gke-ingress gke-build gke-push gke-deploy
	@echo "$(DIVIDER)"
	@echo "$(GREEN)$(BOLD)Deployment complete!$(NC)"
	@$(MAKE) gke-urls
