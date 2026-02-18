# Mobile App Runbook

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| Xcode 15+ | iOS builds | Mac App Store |
| CocoaPods | iOS dependency management | `gem install cocoapods` |
| Android Studio | Android builds | [developer.android.com](https://developer.android.com/studio) |
| Java 17+ | Android builds | `brew install openjdk@17` |

!!! note
    iOS builds require macOS with Xcode installed. Android builds work on macOS, Linux, and Windows.

## First-Time Setup

### 1. Install Dependencies

```bash
cd frontend
pnpm install
```

### 2. Build Web Assets

```bash
pnpm run build
```

### 3. Initialize Native Projects

The iOS and Android projects are already committed to the repository. If they're missing for some reason:

```bash
npx cap add ios
npx cap add android
```

### 4. iOS: Install CocoaPods

```bash
cd ios/App && pod install && cd ../..
```

## Build and Run

### iOS

```bash
# Full build + open Xcode
make mobile-ios

# Or with live reload on simulator
make mobile-run-ios
```

In Xcode:

1. Select a simulator (e.g., iPhone 16)
2. Press **Cmd+R** to build and run

### Android

```bash
# Full build + open Android Studio
make mobile-android

# Or with live reload on emulator
make mobile-run-android
```

In Android Studio:

1. Wait for Gradle sync to complete
2. Select an emulator
3. Press **Run** (green play button)

## Quick Sync (Web Changes Only)

If you've only changed web code (no native plugin changes):

```bash
make mobile-sync
```

This copies the `dist/` directory into the native projects without rebuilding.

## Local HTTPS for iOS Simulator

If the iOS Simulator can't connect to `api.dev.calctek-calc.ai` (SSL errors):

```bash
# Boot a simulator first, then:
make mobile-ssl-ios
```

This installs the mkcert root CA into the simulator's trust store. Restart the app in Xcode after running this.

## All Make Commands

| Command | Description |
|---------|-------------|
| `make mobile-build` | Build Vite + sync to both platforms |
| `make mobile-sync` | Sync web assets only (no rebuild) |
| `make mobile-ios` | Build, sync, open Xcode |
| `make mobile-android` | Build, sync, open Android Studio |
| `make mobile-run-ios` | Run on iOS simulator with live reload |
| `make mobile-run-android` | Run on Android emulator with live reload |
| `make mobile-ssl-ios` | Install mkcert CA into iOS Simulator |

## Troubleshooting

### iOS: "No matching provisioning profiles"

This is normal for simulator builds. Just select "Automatically manage signing" in Xcode under **Signing & Capabilities** and pick your personal team.

### Android: Gradle sync failed

Ensure Java 17+ is installed and `JAVA_HOME` is set:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### Web assets not updating

Run a full sync to ensure native projects have the latest web build:

```bash
make mobile-build
```

### Simulator shows blank screen

Check that `dist/` exists and contains `index.html`:

```bash
ls frontend/dist/index.html
```

If missing, run `pnpm run build` in the `frontend/` directory.
