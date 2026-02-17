# Getting Started

This guide walks you through setting up the CalcTek Calculator project for local development.

## Prerequisites

Before you begin, install the following tools:

| Tool | Purpose | Install |
|------|---------|---------|
| **Docker** | Container runtime | [docker.com](https://www.docker.com/products/docker-desktop/) |
| **docker-compose** | Multi-container orchestration | Included with Docker Desktop |
| **pnpm** | Node.js package manager (frontend) | `npm install -g pnpm` |
| **mkcert** | Local HTTPS certificates | `brew install mkcert` |
| **Make** | Task runner | Pre-installed on macOS |

## First-Time Setup

Run the setup command from the project root:

```bash
make setup
```

This single command performs the following steps:

1. **`make check`** -- Verifies all prerequisites are installed.
2. **`make hosts`** -- Adds local DNS entries to `/etc/hosts` for `api.dev.calctek-calc.ai`, `app.dev.calctek-calc.ai`, and `docs.dev.calctek-calc.ai`.
3. **`make ssl`** -- Generates a wildcard TLS certificate for `*.dev.calctek-calc.ai` using mkcert.
4. **`make network`** -- Creates the `calctek-calc-network` Docker bridge network.
5. **`make launchdaemon`** -- (macOS) Installs a LaunchDaemon to assign the local IP `192.168.204.5` to a loopback alias on boot.

!!! note
    `make setup` requires `sudo` for hosts file and LaunchDaemon modifications. You will be prompted for your password.

## Start the Project

```bash
make start
```

This starts all four containers (Nginx, backend, frontend, docs) in detached mode. Once running, open:

- **Frontend**: [https://app.dev.calctek-calc.ai](https://app.dev.calctek-calc.ai)
- **Backend API**: [https://api.dev.calctek-calc.ai](https://api.dev.calctek-calc.ai)
- **Docs**: [https://docs.dev.calctek-calc.ai](https://docs.dev.calctek-calc.ai)

## Environment Variables

Copy the example environment file to `.env` at the project root (this is done automatically by `make setup` if `.env` does not exist):

```bash
cp .env.example .env
```

Key variables:

| Variable | Description |
|----------|-------------|
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |
| `GOOGLE_REDIRECT_URI` | OAuth callback URL |
| `VITE_API_URL` | Backend URL used by the frontend |
| `LOCAL_IP` | Loopback IP for local DNS (default `192.168.204.5`) |

!!! warning
    Never commit `.env` files. They contain secrets such as OAuth credentials and app keys.

## Useful Commands

```bash
make stop       # Stop all containers
make restart    # Restart all containers
make logs       # Tail all container logs
make logs-be    # Tail backend logs only
make logs-fe    # Tail frontend logs only
make status     # Show container status
make health     # Check backend health endpoint
make migrate    # Run Laravel database migrations
make tinker     # Open Laravel Tinker REPL
make shell-be   # Shell into backend container
make shell-fe   # Shell into frontend container
make build      # Rebuild all containers
```

## Next Steps

- [Local Environment](local-environment.md) -- Detailed environment configuration
- [Backend API](../tech-specs/backend-api.md) -- Backend architecture and GraphQL schema
- [Frontend](../tech-specs/frontend.md) -- Frontend component architecture
