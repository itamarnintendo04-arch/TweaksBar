import Combine
import Foundation
import Network

@MainActor
final class TweaksEngineDiscovery: ObservableObject {
    @Published private(set) var status = "Not connected"
    @Published private(set) var availableHosts: [String] = []
    @Published private(set) var isSearching = false

    private var browser: NWBrowser?

    func start() {
        stop()
        isSearching = true
        status = "Searching for a paired TweaksBar engine…"

        let descriptor = NWBrowser.Descriptor.bonjour(
            type: "_tweaksbar._tcp",
            domain: nil
        )
        let nextBrowser = NWBrowser(for: descriptor, using: .tcp)

        nextBrowser.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    self?.status = "Network discovery is active"
                case .waiting:
                    self?.status = "Waiting for local network permission…"
                case .failed(let error):
                    self?.status = "Discovery unavailable: \(error.localizedDescription)"
                    self?.isSearching = false
                case .cancelled:
                    self?.isSearching = false
                default:
                    break
                }
            }
        }

        nextBrowser.browseResultsChangedHandler = { [weak self] results, _ in
            let hosts = results.compactMap { result -> String? in
                guard case let .service(name, type, domain, _) = result.endpoint else {
                    return nil
                }
                return "\(name).\(type)\(domain)"
            }.sorted()

            Task { @MainActor in
                self?.availableHosts = hosts
                self?.status = hosts.isEmpty
                    ? "No TweaksBar engine found on this network"
                    : "Found \(hosts.count) TweaksBar service(s) — pairing required"
            }
        }

        browser = nextBrowser
        nextBrowser.start(queue: .main)
    }

    func stop() {
        browser?.cancel()
        browser = nil
        isSearching = false
        availableHosts = []
        status = "Not connected"
    }
}
