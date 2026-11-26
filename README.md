# TweaksBar

TweaksBar is a Windows + iPhone companion project for managing iPhone customization workflows.

## Project goals

- Discover and pair an iPhone with a Windows PC over the local network.
- Check for Apple device drivers and guide the user to official installation sources when they are missing.
- Provide a desktop dashboard and an iPhone companion app.
- Build a modular tweak catalog and management experience.
- Research iOS-version-specific capabilities before enabling any system-level customization.

## Important compatibility note

The initial release is a **connection and diagnostics prototype**. It does not jailbreak iOS, inject code into SpringBoard, install system tweaks, or bypass iOS security. Those capabilities require a separately verified, compatible mechanism. No support for iOS 27.3 beta 2 is claimed yet.

## Repository layout

- `Windows/TweaksBar.Client` — WPF desktop application (.NET 10).
- `iOS/TweaksBar` — SwiftUI desktop-pairing companion app source.
- `iOS/TweaksSettings` — separate SwiftUI mobile settings app with device-version display, compatibility status, and a PosterBoard integration page.
- `docs/ARCHITECTURE.md` — system design and security boundaries.

## Development

### Windows

Requirements: Windows 10/11 and the .NET 10 SDK.

```powershell
dotnet run --project .\Windows\TweaksBar.Client\TweaksBar.Client.csproj
```

### iPhone

Open the Swift source in an iOS App project in Xcode on a Mac. Add the local-network and Bonjour usage keys described in `iOS/TweaksBar/Info-Additions.plist` to the app's Info.plist. The companion uses Bonjour discovery for the local network.

## Safety and permissions

- Pairing must be explicitly approved by the user.
- Network communication must be authenticated and encrypted before exchanging device data.
- Apple drivers and Apple software must be obtained from Apple, with the user approving installation.
- Wi-Fi Sync must be enabled by the user in Apple Devices or iTunes; TweaksBar cannot silently enable it.

## iOS apps (XcodeGen)

The repository contains two separate iOS application targets. They are generated from `project.yml`:

- **TweaksBar** — the iPhone companion for discovering a Windows PC.
- **TweaksSettings** — the standalone customization-settings app. Its app icon asset is configured as `AppIcon`.

### Generate and open the Xcode project

On a Mac with Xcode installed:

```bash
brew install xcodegen librsvg
rsvg-convert -w 1024 -h 1024 \
  -o iOS/TweaksSettings/Assets.xcassets/AppIcon.appiconset/AppIcon.png \
  iOS/TweaksSettings/Assets.xcassets/AppIcon.appiconset/AppIcon.svg
xcodegen generate
open TweaksBar.xcodeproj
```

In Xcode, select the **TweaksSettings** scheme to build or run TweaksSettings, or select **TweaksBar** for the companion app. These are separate targets with separate bundle identifiers and separate `@main` entry points.

The `TweaksSettings` target uses `iOS/TweaksSettings/Build/TweaksSettings.xcconfig`, which sets the app icon asset name to `AppIcon`.

A macOS GitHub Actions workflow builds both schemes for the iOS Simulator. A successful simulator build does not mean that privileged iOS modifications or jailbreak integrations are supported; those remain separately unverified.
