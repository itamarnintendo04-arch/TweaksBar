import Foundation

enum CompatibilityVerification: String, Codable {
    case verified
    case partial
    case unsupported
    case unknown

    var displayName: String {
        switch self {
        case .verified: return "Verified"
        case .partial: return "Partial support"
        case .unsupported: return "Not supported"
        case .unknown: return "Not verified"
        }
    }
}

struct JailbreakCompatibilityEntry: Identifiable, Codable {
    let id: String
    let name: String
    let supportedDevices: [String]
    let minimumIOSVersion: String?
    let maximumIOSVersion: String?
    let verification: CompatibilityVerification
    let lastVerified: String?
    let sourceName: String?
    var sourceURL: URL?
    let notes: String

    func matches(deviceIdentifier: String, iosVersion: String) -> Bool {
        let deviceMatches = supportedDevices.isEmpty || supportedDevices.contains(deviceIdentifier)
        guard deviceMatches else { return false }

        // Version ranges are intentionally not guessed here. Until a trusted
        // catalog supplies verified bounds, an entry must remain unverified.
        return minimumIOSVersion == nil && maximumIOSVersion == nil
            ? verification == .verified
            : false
    }
}

enum JailbreakCompatibilityCatalog {
    /// Empty by design: no jailbreak support claim is published until the
    /// exact device + iOS build combination has been checked against sources.
    static let entries: [JailbreakCompatibilityEntry] = []

    static func entries(for deviceIdentifier: String, iosVersion: String) -> [JailbreakCompatibilityEntry] {
        entries.filter { $0.matches(deviceIdentifier: deviceIdentifier, iosVersion: iosVersion) }
    }
}
