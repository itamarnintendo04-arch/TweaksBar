import SwiftUI

struct TweaksSettingsRootView: View {
    var body: some View {
        TabView {
            SettingsHomeView()
                .tabItem {
                    Label("Home", systemImage: "square.grid.2x2")
                }

            CompatibilityView()
                .tabItem {
                    Label("Compatibility", systemImage: "checkmark.shield")
                }

            PosterBoardSettingsView()
                .tabItem {
                    Label("PosterBoard", systemImage: "photo.on.rectangle.angled")
                }
        }
        .tint(Color(red: 0.20, green: 0.48, blue: 1.0))
        .preferredColorScheme(.dark)
    }
}

private struct SettingsHomeView: View {
    private let device = DeviceCompatibility.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.16, green: 0.43, blue: 0.96),
                                            Color(red: 0.08, green: 0.28, blue: 0.72)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Image(systemName: "gearshape.2")
                                .font(.system(size: 46, weight: .semibold))
                                .overlay {
                                    Image(systemName: "screwdriver")
                                        .font(.system(size: 24, weight: .bold))
                                        .rotationEffect(.degrees(-42))
                                }
                                .foregroundStyle(.white)
                        }
                        .frame(width: 104, height: 104)

                        Text("TweaksSettings")
                            .font(.largeTitle.bold())

                        Text("Your iPhone customization center")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 22)

                    infoCard(
                        title: "Your Device",
                        value: "\(device.deviceName) · \(device.systemName) \(device.systemVersion)",
                        symbol: "iphone"
                    )

                    NavigationLink {
                        CompatibilityView()
                    } label: {
                        destinationCard(
                            title: "Compatibility",
                            subtitle: "Review verified support for this iOS version.",
                            symbol: "checkmark.shield"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PosterBoardSettingsView()
                    } label: {
                        destinationCard(
                            title: "PosterBoard",
                            subtitle: "PosterBoard settings and integration status.",
                            symbol: "photo.on.rectangle.angled"
                        )
                    }
                    .buttonStyle(.plain)

                    Text("System changes stay unavailable until a compatible, verified integration is present.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding()
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Home")
        }
    }

    private func infoCard(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 38)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(value).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func destinationCard(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 38)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(.primary)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct CompatibilityView: View {
    private let device = DeviceCompatibility.current

    var body: some View {
        NavigationStack {
            List {
                Section("Detected device") {
                    LabeledContent("Device", value: device.deviceName)
                    LabeledContent("Operating system", value: device.systemName)
                    LabeledContent("Version", value: device.systemVersion)
                }

                Section("Modification support") {
                    HStack {
                        Label("Environment status", systemImage: "questionmark.circle")
                        Spacer()
                        Text(device.modificationEnvironmentStatus)
                            .foregroundStyle(.orange)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Compatibility catalog")
                            .font(.headline)
                        Text(device.catalogStatus)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Text("iOS apps run inside Apple's app sandbox. TweaksSettings will only mark a jailbreak or tweak integration as supported after its compatibility has been independently verified. A standard app cannot reliably detect every modified system state.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Compatibility")
        }
    }
}

#Preview {
    TweaksSettingsRootView()
}
