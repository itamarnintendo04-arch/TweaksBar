import SwiftUI

@main
struct TweaksBarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

@MainActor
struct ContentView: View {
    @StateObject private var discovery = DeviceDiscovery()

    private let background = Color(red: 0.025, green: 0.055, blue: 0.13)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            RadialGradient(
                colors: [Color.blue.opacity(0.34), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    hero
                    connectionCard
                    discoveryCard
                    setupCard
                    footer
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.10, green: 0.43, blue: 0.98), Color(red: 0.03, green: 0.18, blue: 0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "cable.connector")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("TweaksBar")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("IPHONE COMPANION")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.blue.opacity(0.85))
            }
            Spacer()
            statusPill
        }
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(discovery.discoveredDevices.isEmpty ? Color.orange : Color.green)
                .frame(width: 6, height: 6)
            Text(discovery.discoveredDevices.isEmpty ? "NOT CONNECTED" : "PC FOUND")
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.07), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.09), lineWidth: 1))
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("YOUR IPHONE,")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(Color(red: 0.55, green: 0.76, blue: 1))

            Text("Connected to
your workspace.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-0.8)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Find your TweaksBar desktop app on the same trusted network and manage your companion connection.")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.76, green: 0.83, blue: 0.94))
                .lineSpacing(4)

            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(Color(red: 0.58, green: 0.79, blue: 1))
                Text("Local network discovery")
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.top, 4)
        }
        .padding(23)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.29, blue: 0.61), Color(red: 0.06, green: 0.13, blue: 0.30)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.blue.opacity(0.22))
                        .frame(width: 170, height: 170)
                        .blur(radius: 22)
                        .offset(x: 48, y: -65)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Connection", subtitle: "Discover your Windows computer")

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.blue.opacity(0.14))
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color(red: 0.49, green: 0.72, blue: 1))
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(discovery.status)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Both devices must be on the same network.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.48))
                }
                Spacer(minLength: 0)
            }

            Button {
                discovery.startDiscovery()
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Find My PC")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.52, blue: 1), Color(red: 0.10, green: 0.34, blue: 0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                )
            }
            .buttonStyle(.plain)

            Button("Stop discovery") {
                discovery.stopDiscovery()
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.top, 1)
        }
        .padding(19)
        .panelStyle()
    }

    private var discoveryCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeading("Available computers", subtitle: "TweaksBar services on your network")

            if discovery.discoveredDevices.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.35))
                    Text("No computers found yet. Start discovery to search again.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.52))
                }
                .padding(.vertical, 9)
            } else {
                ForEach(discovery.discoveredDevices, id: \.self) { device in
                    HStack(spacing: 11) {
                        Image(systemName: "desktopcomputer")
                            .foregroundStyle(.green)
                        Text(device)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("FOUND")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .padding(12)
                    .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(19)
        .panelStyle()
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Before you connect", subtitle: "A quick setup checklist")

            setupRow(number: "01", title: "Open TweaksBar on Windows", detail: "Keep the desktop app running.")
            setupRow(number: "02", title: "Connect to the same Wi-Fi", detail: "Your iPhone and PC must share a local network.")
            setupRow(number: "03", title: "Allow Local Network access", detail: "iOS asks for permission the first time you search.")
        }
        .padding(19)
        .panelStyle()
    }

    private var footer: some View {
        Text("TweaksBar only discovers the local network service. Pairing and device actions require a separate, user-approved secure connection.")
            .font(.system(size: 10))
            .foregroundStyle(.white.opacity(0.38))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 8)
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.48))
        }
    }

    private func setupRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.53, green: 0.75, blue: 1))
                .frame(width: 30, height: 30)
                .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.48))
            }
            Spacer(minLength: 0)
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        self
            .background(Color(red: 0.055, green: 0.085, blue: 0.16), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .stroke(.white.opacity(0.075), lineWidth: 1)
            )
    }
}
