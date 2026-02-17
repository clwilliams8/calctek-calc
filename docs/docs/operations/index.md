# Operations

Operational documentation for deploying and managing the CalcTek Calculator in production.

## Overview

The production environment runs on **Google Kubernetes Engine (GKE)** with an Nginx Ingress Controller for routing and sslip.io for wildcard DNS.

## Runbooks

| Runbook | Description |
|---------|-------------|
| [GKE Deployment](gke-runbook.md) | Full deployment, troubleshooting, and teardown procedures |

## Quick Reference

| Command | Description |
|---------|-------------|
| `make gke-deploy-all` | One-command full deployment |
| `make gke-status` | Check pod and service status |
| `make gke-urls` | Print live sslip.io URLs |
| `make gke-logs` | Tail all pod logs |
| `make gke-health` | Check backend health endpoint |
| `make gke-destroy` | Full teardown (cluster + registry) |
