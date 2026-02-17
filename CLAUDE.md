# CalcTek Calculator - Claude Code Context

## Project Overview
API-driven calculator with GraphQL backend, Vue.js frontend, Google OAuth, and calculation history.

## Local URLs
- **Frontend**: https://app.dev.calctek-calc.ai
- **Backend API**: https://api.dev.calctek-calc.ai
- **GraphQL Playground**: https://api.dev.calctek-calc.ai/graphql-playground
- **Docs**: https://docs.dev.calctek-calc.ai

## GraphQL Endpoints
- `POST /graphql` - GraphQL API (requires Bearer token)
- `GET /auth/google/redirect` - Initiate Google OAuth
- `GET /auth/google/callback` - Google OAuth callback
- `GET /health` - Health check

## Architecture
- **Backend**: Laravel 11 + Lighthouse GraphQL (PHP-FPM on port 9000) — Nginx forwards via FastCGI
- **Frontend**: Vue 3 + Vite + shadcn-vue + Apollo Client
- **Auth**: Google OAuth via Socialite + Sanctum tokens
- **Database**: SQLite
- **Docs**: MkDocs Material (Document-Driven Development)
- **Infrastructure**: Docker Compose + Nginx reverse proxy + mkcert SSL

## Key Commands
```bash
make setup   # First-time setup (hosts, SSL, network, launchdaemon)
make start   # Start all containers
make stop    # Stop all containers
make logs    # Follow all container logs
make migrate # Run database migrations
```

## GitHub Account
This project uses the **clwilliams8** GitHub account (`colton@coltons-apps.tech`).
Before starting any new feature or pushing code, verify the correct account is active:
```bash
ghwho          # Check which GitHub account is active
ghme           # Switch to clwilliams8 (personal)
ghrm           # Switch to colton-williams-roofmaxx (work)
```
If `ghwho` does not show `clwilliams8` as the active account, run `ghme` before proceeding.

## Development Rules
- SPA only — no page reloads, use vue-router
- Never commit .env or API keys
- Use `make` commands for setup/start/stop
- Backend source is at /var/www/html inside containers
- Nginx needs backend source mounted for FastCGI SCRIPT_FILENAME resolution
- All API access requires authentication (Sanctum Bearer token)
- GraphQL schema is the source of truth for API contract
