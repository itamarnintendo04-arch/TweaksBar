import Darwin
import Foundation
import UIKit

struct DeviceCompatibility {
    let deviceName: String
    let systemName: String
    let systemVersion: String
    let modelIdentifier: String

    static var current: DeviceCompatibility {
        let device = UIDevice.current
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }

        return DeviceCompatibility(
            deviceName: device.localizedModel,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            modelIdentifier: identifier
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
