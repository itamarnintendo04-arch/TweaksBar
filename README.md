# TweaksBar

TweaksBar is a Windows + iPhone companion project for managing iPhone customization workflows.

## Project goals

- Discover and pair an iPhone with a Windows PC over the local network.
- Check for Apple device drivers and guide the user to official installation sources when they are missing.
- Provide a desktop dashboard and an iPhone companion app.
- Build a modular tweak catalog and management experience.
- Research iOS-version-specific capabilities before enabling any system-level customization.

## Important compatibility note

The Windows app includes a redesigned desktop workspace, a release downloader, IPA/ZIP import and archive validation, local package storage, Apple driver checks, and Windows Plug and Play-based iPhone detection. The iPhone companion includes a redesigned local-network discovery interface. Apple ID signing and direct USB installation are not yet implemented; the install action remains disabled until a supported signing and installation integration is available. The app does not jailbreak iOS, inject code into SpringBoard, install system tweaks, or bypass iOS security. No support for a specific beta iOS build is claimed unless it appears in the verified compatibility catalog.

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

The macOS GitHub Actions workflows build both schemes for generic iOS devices and package unsigned IPA archives. These IPAs are not directly installable until signed with a valid Apple provisioning profile. A successful device build does not mean that privileged iOS modifications or jailbreak integrations are supported; those remain separately unverified.
\n## Windows desktop preview\n\nThe Windows client has four sections: Overview, Install IPA, Device support, and Settings. The package importer accepts a standalone `.ipa` or a ZIP containing IPA files at its root, and copies/imports those packages into the current user's local TweaksBar package folder. The install button remains disabled until Apple signing and the USB installation bridge are implemented and tested.\n