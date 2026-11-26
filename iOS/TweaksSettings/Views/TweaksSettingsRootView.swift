import SwiftUI

private enum TweaksPalette {
    static let blue = Color(red: 0.20, green: 0.48, blue: 1.00)
    static let cyan = Color(red: 0.30, green: 0.78, blue: 1.00)
    static let background = Color(red: 0.035, green: 0.055, blue: 0.095)
    static let surface = Color(red: 0.075, green: 0.105, blue: 0.16)
    static let muted = Color.white.opacity(0.58)
}

struct TweaksSettingsRootView: View {
    var body: some View {
        TabView {
            SettingsHomeView()
                .tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }
            TweaksLibraryView()
                .tabItem { Label("Tweaks", systemImage: "slider.horizontal.3") }
            PosterBoardSettingsView()
                .tabItem { Label("PosterBoard", systemImage: "rectangle.stack.fill") }
            CompatibilityView()
                .tabItem { Label("Compatibility", systemImage: "checkmark.shield.fill") }
        }
        .tint(TweaksPalette.cyan)
        .preferredColorScheme(.dark)
    }
}

private struct SettingsHomeView: View {
    private let device = DeviceCompatibility.current

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    deviceCard
                    EngineConnectionView()
                    HStack(spacing: 12) {
                        statusTile(title: "Compatibility", value: "Checking catalog", icon: "checkmark.shield", tint: TweaksPalette.cyan)
                        statusTile(title: "System Changes", value: "Disabled", icon: "lock.shield", tint: .orange)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeading("Explore", subtitle: "Your customization workspace")
                        NavigationLink { TweaksLibraryView() } label: {
                            destinationCard(title: "Tweak Library", subtitle: "Browse available customization modules", icon: "slider.horizontal.3", accent: TweaksPalette.cyan)
                        }.buttonStyle(.plain)
                        NavigationLink { PosterBoardSettingsView() } label: {
                            destinationCard(title: "PosterBoard Studio", subtitle: "Wallpaper and PosterBoard integration", icon: "rectangle.stack.fill", accent: Color.purple)
                        }.buttonStyle(.plain)
                        NavigationLink { CompatibilityView() } label: {
                            destinationCard(title: "Compatibility Center", subtitle: "Check verified support for this device", icon: "checkmark.shield.fill", accent: Color.green)
                        }.buttonStyle(.plain)
                    }
                    Text("TweaksSettings only enables system changes when a compatible integration has been verified.")
                        .font(.footnote)
                        .foregroundStyle(TweaksPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .background(TweaksPalette.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(LinearGradient(colors: [TweaksPalette.blue, Color(red: 0.08, green: 0.25, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: "gearshape.2")
                    .font(.system(size: 31, weight: .semibold))
                    .overlay {
                        Image(systemName: "screwdriver")
                            .font(.system(size: 16, weight: .bold))
                            .rotationEffect(.degrees(-42))
                    }
                    .foregroundStyle(.white)
            }
            .frame(width: 62, height: 62)
            VStack(alignment: .leading, spacing: 4) {
                Text("TweaksSettings").font(.title2.bold()).foregroundStyle(.white)
                Text("Your iPhone customization center").font(.caption).foregroundStyle(TweaksPalette.muted)
            }
            Spacer()
            Image(systemName: "ellipsis")
                .font(.title3.bold())
                .foregroundStyle(TweaksPalette.muted)
                .padding(10)
                .background(.white.opacity(0.07), in: Circle())
        }
        .padding(.top, 8)
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("CONNECTED DEVICE", systemImage: "iphone")
                    .font(.caption2.bold())
                    .tracking(1.1)
                    .foregroundStyle(TweaksPalette.cyan)
                Spacer()
                Circle().fill(Color.orange).frame(width: 7, height: 7)
                Text("Local device").font(.caption2).foregroundStyle(TweaksPalette.muted)
            }
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 58, height: 72)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 5) {
                    Text(device.deviceName).font(.headline).foregroundStyle(.white)
                    Text("\(device.systemName) \(device.systemVersion)")
                        .font(.subheadline).foregroundStyle(TweaksPalette.muted)
                    Text(device.modelIdentifier)
                        .font(.caption2.monospaced()).foregroundStyle(TweaksPalette.muted)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .background(
            LinearGradient(colors: [Color(red: 0.10, green: 0.20, blue: 0.34), TweaksPalette.surface], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private func statusTile(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(tint)
            Text(title).font(.caption).foregroundStyle(TweaksPalette.muted)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.06), lineWidth: 1))
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.title3.bold()).foregroundStyle(.white)
            Text(subtitle).font(.caption).foregroundStyle(TweaksPalette.muted)
        }
    }

    private func destinationCard(title: String, subtitle: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(accent)
                .frame(width: 46, height: 46)
                .background(accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold()).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(TweaksPalette.muted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(TweaksPalette.muted)
        }
        .padding(14)
        .background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.06), lineWidth: 1))
    }
}

private struct TweaksLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private let categories = ["All", "Appearance", "Lock Screen", "System"]
    private let modules: [(name: String, detail: String, icon: String, category: String)] = [
        ("App Icon & Name", "Custom app labels and icon integration", "app.dashed", "Appearance"),
        ("PosterBoard", "Wallpaper and Lock Screen customization", "rectangle.stack", "Lock Screen"),
        ("Control Center", "Control Center layout integrations", "switch.2", "System"),
        ("Home Screen", "Home Screen layout and visual options", "square.grid.3x3", "Appearance")
    ]

    private var filteredModules: [(name: String, detail: String, icon: String, category: String)] {
        modules.filter {
            (selectedCategory == "All" || $0.category == selectedCategory) &&
            (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) || $0.detail.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Tweak Library").font(.largeTitle.bold()).foregroundStyle(.white)
                        Text("Explore customization modules for your device.")
                            .font(.subheadline).foregroundStyle(TweaksPalette.muted)
                    }
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(TweaksPalette.muted)
                        TextField("Search tweaks", text: $searchText).foregroundStyle(.white)
                    }
                    .padding(13)
                    .background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 14))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                Button { selectedCategory = category } label: {
                                    Text(category).font(.caption.weight(.semibold))
                                        .padding(.horizontal, 14).padding(.vertical, 9)
                                        .background(selectedCategory == category ? TweaksPalette.blue : TweaksPalette.surface, in: Capsule())
                                        .foregroundStyle(.white)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    ForEach(filteredModules, id: \.name) { module in
                        HStack(spacing: 14) {
                            Image(systemName: module.icon).font(.title2).foregroundStyle(TweaksPalette.cyan)
                                .frame(width: 48, height: 48)
                                .background(TweaksPalette.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 15))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(module.name).font(.subheadline.bold()).foregroundStyle(.white)
                                Text(module.detail).font(.caption).foregroundStyle(TweaksPalette.muted)
                                Text("INTEGRATION NOT AVAILABLE")
                                    .font(.system(size: 9, weight: .bold)).tracking(0.8)
                                    .foregroundStyle(.orange).padding(.top, 3)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "lock.fill").font(.caption).foregroundStyle(TweaksPalette.muted)
                        }
                        .padding(14)
                        .background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 19))
                    }
                    Text("These are planned module categories, not installed tweaks. No system changes are made from this screen.")
                        .font(.footnote).foregroundStyle(TweaksPalette.muted)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .background(TweaksPalette.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct CompatibilityView: View {
    private let device = DeviceCompatibility.current
    @StateObject private var catalog = CompatibilityCatalogService()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Compatibility").font(.largeTitle.bold()).foregroundStyle(.white)
                        Text("Verified support for your exact device and iOS version.")
                            .font(.subheadline).foregroundStyle(TweaksPalette.muted)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Label("THIS DEVICE", systemImage: "iphone").font(.caption2.bold()).tracking(1).foregroundStyle(TweaksPalette.cyan)
                        Text(device.deviceName).font(.headline).foregroundStyle(.white)
                        Text("\(device.modelIdentifier) · \(device.systemName) \(device.systemVersion)")
                            .font(.caption.monospaced()).foregroundStyle(TweaksPalette.muted)
                    }
                    .padding(17).frame(maxWidth: .infinity, alignment: .leading)
                    .background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Jailbreak compatibility").font(.headline).foregroundStyle(.white)
                            Spacer()
                            Button { Task { await catalog.refresh() } } label: {
                                if catalog.isLoading { ProgressView().tint(TweaksPalette.cyan) }
                                else { Label("Refresh", systemImage: "arrow.clockwise").font(.caption.bold()) }
                            }.disabled(catalog.isLoading)
                        }
                        Text(catalog.status).font(.subheadline).foregroundStyle(TweaksPalette.muted)
                        if let updated = catalog.lastUpdated {
                            Text("Catalog updated: \(updated)").font(.caption2).foregroundStyle(TweaksPalette.muted)
                        }
                        let matches = catalog.entries.filter {
                            $0.matches(deviceIdentifier: device.modelIdentifier, iosVersion: device.systemVersion)
                        }
                        if matches.isEmpty {
                            Label("No verified entries for this device", systemImage: "exclamationmark.shield")
                                .font(.subheadline.weight(.semibold)).foregroundStyle(.orange)
                            Text("This does not prove that no jailbreak exists. The catalog currently has no verified match.")
                                .font(.caption).foregroundStyle(TweaksPalette.muted)
                        } else {
                            ForEach(matches) { entry in
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text(entry.name).font(.subheadline.bold()).foregroundStyle(.white)
                                        Spacer()
                                        Text(entry.verification.displayName).font(.caption2.bold()).foregroundStyle(entry.verification == .verified ? .green : .orange)
                                    }
                                    Text(entry.notes).font(.caption).foregroundStyle(TweaksPalette.muted)
                                    if let sourceURL = entry.sourceURL {
                                        Link(entry.sourceName ?? "Compatibility source", destination: sourceURL).font(.caption)
                                    }
                                }.padding(12).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 13))
                            }
                        }
                    }
                    .padding(17).background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Environment detection", systemImage: "lock.shield").font(.headline).foregroundStyle(.white)
                        Text("Jailbreak state: \(device.modificationEnvironmentStatus)")
                            .font(.subheadline).foregroundStyle(.orange)
                        Text("A regular iOS app cannot reliably confirm every modified system state. Compatibility records and on-device detection are separate.")
                            .font(.caption).foregroundStyle(TweaksPalette.muted)
                    }
                    .padding(17).background(TweaksPalette.surface, in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
            }
            .background(TweaksPalette.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .task { await catalog.refresh() }
    }
}

#Preview {
    TweaksSettingsRootView()
}
