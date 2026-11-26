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
- `iOS/TweaksBar` — SwiftUI companion app source.
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
