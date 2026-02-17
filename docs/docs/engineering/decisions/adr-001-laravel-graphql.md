# ADR-001: Laravel + Lighthouse GraphQL

## Status

**Accepted**

## Context

CalcTek Calculator needs a backend API to handle calculations, user authentication, and history persistence. The API contract must be well-defined, strongly typed, and efficient for a single-page application that makes multiple related queries.

Options considered:

1. **Laravel + REST API** -- Traditional REST endpoints with JSON responses.
2. **Laravel + Lighthouse GraphQL** -- GraphQL API with the Lighthouse schema-first package.
3. **Node.js (Express/Fastify) + GraphQL** -- JavaScript-based backend with Apollo Server or Mercurius.

## Decision

Use **Laravel 11 with Lighthouse GraphQL**.

## Rationale

- **Schema-first development**: Lighthouse's `.graphql` schema file serves as the single source of truth for the API contract, aligning with the project's document-driven development approach.
- **Strong typing**: GraphQL's type system catches contract mismatches at build time rather than runtime. The `Calculation`, `User`, and `CalculateInput` types are explicitly defined.
- **Single endpoint**: The frontend needs to fetch user data, perform calculations, and query history. GraphQL's single endpoint with flexible queries reduces the number of HTTP round trips compared to REST.
- **Laravel ecosystem**: Sanctum (auth tokens), Socialite (OAuth), Eloquent (ORM), and Artisan (CLI) provide battle-tested solutions for authentication, database management, and developer tooling.
- **Lighthouse integration**: Lighthouse maps GraphQL types directly to Eloquent models and provides directives like `@guard`, `@auth`, and `@field` that reduce boilerplate.

## Consequences

- Developers must understand both Laravel and GraphQL concepts.
- The GraphQL schema file (`backend/graphql/schema.graphql`) must be kept in sync with resolvers and models.
- Lighthouse's directive-based approach adds a layer of "magic" that can be opaque to newcomers.
