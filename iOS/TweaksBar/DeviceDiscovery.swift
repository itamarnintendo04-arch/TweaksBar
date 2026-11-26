import Combine
import Foundation
import Network

@MainActor
final class DeviceDiscovery: ObservableObject {
    @Published private(set) var status = "Ready to discover your PC"
    @Published private(set) var discoveredDevices: [String] = []

    private var browser: NWBrowser?

    func startDiscovery() {
        stopDiscovery()
        status = "Searching your local network…"

        let descriptor = NWBrowser.Descriptor.bonjour(
            type: "_tweaksbar._tcp",
            domain: nil
        )
        let newBrowser = NWBrowser(for: descriptor, using: .tcp)

        newBrowser.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.status = "Local network discovery is active"
                case .failed(let error):
                    self?.status = "Discovery failed: \(error.localizedDescription)"
                case .waiting:
                    self?.status = "Waiting for network access…"
                case .cancelled:
                    self?.status = "Discovery stopped"
                default:
                    break
                }
            }
        }

        newBrowser.browseResultsChangedHandler = { [weak self] results, _ in
            let names = results.compactMap { result -> String? in
                guard case let .service(name, _, _, _) = result.endpoint else {
                    return nil
                }
                return name
            }.sorted()

            Task { @MainActor in
                self?.discoveredDevices = names
                self?.status = names.isEmpty
                    ? "No TweaksBar PCs found yet"
                    : "Found \(names.count) TweaksBar service(s)"
            }
        }

        browser = newBrowser
        newBrowser.start(queue: .main)
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
        discoveredDevices = []
    }
}
