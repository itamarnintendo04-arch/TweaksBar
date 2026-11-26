# TweaksBar Architecture

## Components

### Windows client
The Windows desktop client is the control center. It will:
- inspect whether Apple Mobile Device Support is present;
- show connection and pairing state;
- guide the user through Apple's Wi-Fi Sync setup;
- discover the iPhone companion over Bonjour;
- expose the tweak catalog only after the device capability checks pass.

### iPhone companion
The iPhone app requests Local Network access when the user starts device discovery. It advertises/discovers only the TweaksBar service on the local network. It does not request unrelated permissions.

### Device bridge
The bridge will use a documented, versioned protocol. Before any pairing data is exchanged, the user must approve a pairing request. The eventual transport must use authenticated TLS and short-lived pairing credentials.

## Apple driver setup

TweaksBar checks for Apple Mobile Device Support and Apple Mobile Device Service. If they are missing, the UI directs the user to Apple's official installation instructions. The installer must not download drivers from third-party mirrors or install software without user consent.

## Wi-Fi Sync

Wi-Fi Sync is configured by the user in Apple Devices or iTunes on Windows. TweaksBar can provide instructions and verify whether the device is discoverable, but it cannot turn on Apple's sync setting remotely or bypass the initial USB trust/pairing flow.

## Tweak engine boundary

The first milestone is diagnostics and secure device discovery. The app must not claim it can rename SpringBoard icons or inject tweaks until a compatible iOS execution mechanism is independently verified for the target iOS build. Unsupported devices should remain in diagnostics-only mode.
