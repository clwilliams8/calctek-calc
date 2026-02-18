# ADR-004: CapacitorJS for Native Mobile Apps

**Status:** Accepted

## Context

CalcTek Calculator is a web application that needs to be distributed as native iOS and Android apps. The entire UI is built with Vue 3 + Vite and communicates with a backend API over GraphQL. We need a way to package this web app into native mobile apps without rewriting the frontend.

## Decision

Use **CapacitorJS** to wrap the existing Vue 3 SPA into native iOS and Android applications.

## Rationale

| Factor | CapacitorJS |
|--------|-------------|
| **Code sharing** | 100% — same Vue 3 codebase runs in native WebView |
| **Web-first** | Designed for web apps; the web build IS the mobile app |
| **Native APIs** | Plugin system for camera, filesystem, push notifications, etc. |
| **Build tool** | Works with any web framework (Vue, React, Angular) |
| **Maintenance** | Actively maintained by Ionic team |
| **Migration path** | Can incrementally add native Swift/Kotlin code as needed |

## Alternatives Considered

### React Native
- **Rejected:** Would require a complete UI rewrite from Vue to React
- Overkill for a calculator app that works well as a web view

### Progressive Web App (PWA)
- **Rejected:** Limited native API access, no App Store distribution, inconsistent iOS support for service workers

### Apache Cordova
- **Rejected:** Legacy project, Capacitor is its spiritual successor with better architecture and active maintenance

## Consequences

### Positive
- Zero frontend code duplication — one codebase for web, iOS, and Android
- Fast iteration — `make mobile-ios` builds and opens Xcode in seconds
- Live reload development with `make mobile-run-ios`
- Native app store distribution possible

### Negative
- Performance bound by WebView (adequate for a calculator)
- Some native features require custom Capacitor plugins
- iOS and Android project files must be committed and maintained
- Requires Xcode (macOS only) for iOS builds
