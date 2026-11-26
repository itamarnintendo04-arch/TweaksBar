import SwiftUI

@main
struct TweaksBarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@MainActor
struct ContentView: View {
    @StateObject private var discovery = DeviceDiscovery()

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.purple)

                Text("TweaksBar")
                    .font(.largeTitle.bold())

                Text("Connect your iPhone to TweaksBar on Windows.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {
                    Label(discovery.status, systemImage: "wifi")
                        .font(.subheadline)
                    ForEach(discovery.discoveredDevices, id: \.self) { device in
                        Label(device, systemImage: "desktopcomputer")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Button {
                    discovery.startDiscovery()
                } label: {
                    Text("Find My PC")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("Stop Discovery") {
                    discovery.stopDiscovery()
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}
