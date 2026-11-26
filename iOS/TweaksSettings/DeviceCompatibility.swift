import Foundation
import UIKit

struct DeviceCompatibility {
    let deviceName: String
    let systemName: String
    let systemVersion: String

    static var current: DeviceCompatibility {
        let device = UIDevice.current
        return DeviceCompatibility(
            deviceName: device.localizedModel,
            systemName: device.systemName,
            systemVersion: device.systemVersion
        )
    }

    /// A normal App Store-style iOS app cannot reliably verify jailbreak
    /// state or the availability of privileged system modification APIs.
    var modificationEnvironmentStatus: String {
        "Not verified"
    }

    var catalogStatus: String {
        "No compatibility entry has been verified for this device yet."
    }
}
