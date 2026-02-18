# Engineering

Technical documentation for the CalcTek Calculator project, including onboarding guides, architecture specs, and decision records.

## Sections

| Section | Description |
|---------|-------------|
| [Getting Started](onboarding/getting-started.md) | Prerequisites and first-time setup |
| [Local Environment](onboarding/local-environment.md) | Running the project locally with Docker |
| [Backend API](tech-specs/backend-api.md) | Laravel 11, Lighthouse GraphQL, Sanctum auth |
| [Frontend](tech-specs/frontend.md) | Vue 3, Vite, shadcn-vue, Apollo Client |
| [Mobile Apps](tech-specs/mobile.md) | CapacitorJS for iOS and Android |
| [Infrastructure](tech-specs/infrastructure.md) | Docker Compose, Nginx, GKE Kubernetes |

## Architecture Decisions

| ADR | Title |
|-----|-------|
| [ADR-001](decisions/adr-001-laravel-graphql.md) | Laravel + Lighthouse GraphQL |
| [ADR-002](decisions/adr-002-sqlite.md) | SQLite as the database |
| [ADR-003](decisions/adr-003-google-oauth.md) | Google OAuth with Socialite + Sanctum |
| [ADR-004](decisions/adr-004-capacitorjs.md) | CapacitorJS for native mobile apps |
