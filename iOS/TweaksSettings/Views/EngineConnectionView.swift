import SwiftUI

struct EngineConnectionView: View {
    @StateObject private var discovery = TweaksEngineDiscovery()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("TweaksBar Engine", systemImage: "cpu")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Circle()
                    .fill(discovery.isSearching ? Color.cyan : Color.orange)
                    .frame(width: 8, height: 8)
            }

            Text(discovery.status)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))

            if !discovery.availableHosts.isEmpty {
                ForEach(discovery.availableHosts, id: \.self) { host in
                    Label(host, systemImage: "desktopcomputer")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
                Text("A secure pairing step is required before this app can send any request.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 10) {
                Button {
                    discovery.start()
                } label: {
                    Label("Find Engine", systemImage: "wifi")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.20, green: 0.48, blue: 1.00))
                .disabled(discovery.isSearching)

                Button("Stop") {
                    discovery.stop()
                }
                .buttonStyle(.bordered)
                .disabled(!discovery.isSearching)
            }
        }
        .padding(17)
        .background(Color(red: 0.075, green: 0.105, blue: 0.16), in: RoundedRectangle(cornerRadius: 20))
    }
}
