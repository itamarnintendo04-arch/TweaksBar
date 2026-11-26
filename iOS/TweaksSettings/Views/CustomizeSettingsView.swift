import SwiftUI

private enum CustomizeColors {
    static let background = Color(red: 0.035, green: 0.055, blue: 0.095)
    static let surface = Color(red: 0.075, green: 0.105, blue: 0.16)
    static let blue = Color(red: 0.20, green: 0.48, blue: 1.00)
    static let cyan = Color(red: 0.30, green: 0.78, blue: 1.00)
    static let muted = Color.white.opacity(0.58)
}

struct CustomizeSettingsView: View {
    @State private var selectedAccent = "Blue"
    @State private var selectedIconStyle = "Default"
    @State private var showLabels = true

    private let accents: [(name: String, color: Color)] = [
        ("Blue", Color(red: 0.20, green: 0.48, blue: 1.00)),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Green", .green),
        ("Orange", .orange)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Customize").font(.largeTitle.bold()).foregroundStyle(.white)
                        Text("Personalize the look and feel of your iPhone.")
                            .font(.subheadline).foregroundStyle(CustomizeColors.muted)
                    }

                    previewCard

                    VStack(alignment: .leading, spacing: 15) {
                        sectionTitle("Accent color", subtitle: "Choose a color for supported interface elements")
                        HStack(spacing: 14) {
                            ForEach(accents, id: \.name) { accent in
                                Button {
                                    selectedAccent = accent.name
                                } label: {
                                    VStack(spacing: 7) {
                                        Circle().fill(accent.color)
                                            .frame(width: 37, height: 37)
                                            .overlay {
                                                if selectedAccent == accent.name {
                                                    Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                                                }
                                            }
                                            .overlay(Circle().stroke(.white.opacity(selectedAccent == accent.name ? 0.9 : 0.12), lineWidth: selectedAccent == accent.name ? 2 : 1))
                                        Text(accent.name).font(.caption2).foregroundStyle(CustomizeColors.muted)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(17)
                    .background(CustomizeColors.surface, in: RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 13) {
                        sectionTitle("Icon appearance", subtitle: "Preview different icon presentation styles")
                        Picker("Icon style", selection: $selectedIconStyle) {
                            Text("Default").tag("Default")
                            Text("Rounded").tag("Rounded")
                            Text("Minimal").tag("Minimal")
                        }
                        .pickerStyle(.segmented)
                        Toggle(isOn: $showLabels) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Show app labels").foregroundStyle(.white)
                                Text("Preview label visibility").font(.caption).foregroundStyle(CustomizeColors.muted)
                            }
                        }
                        .tint(CustomizeColors.cyan)
                    }
                    .padding(17)
                    .background(CustomizeColors.surface, in: RoundedRectangle(cornerRadius: 20))

                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill").foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("System integration not verified").font(.subheadline.bold()).foregroundStyle(.white)
                            Text("These controls currently update this preview only. Applying changes to iOS requires a verified compatible integration.")
                                .font(.caption).foregroundStyle(CustomizeColors.muted)
                        }
                    }
                    .padding(15)
                    .background(CustomizeColors.surface, in: RoundedRectangle(cornerRadius: 18))

                    Button {} label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Apply to iOS")
                        }
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 15))
                    }
                    .disabled(true)
                }
                .padding(20)
            }
            .background(CustomizeColors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var previewCard: some View {
        let accent = accents.first(where: { $0.name == selectedAccent })?.color ?? CustomizeColors.blue
        return VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("LIVE PREVIEW", systemImage: "sparkles")
                    .font(.caption2.bold()).tracking(1).foregroundStyle(CustomizeColors.cyan)
                Spacer()
                Text("Preview only").font(.caption2).foregroundStyle(CustomizeColors.muted)
            }
            HStack(spacing: 13) {
                previewIcon("message.fill", color: accent)
                previewIcon("camera.fill", color: .gray)
                previewIcon("music.note", color: .pink)
                previewIcon("gearshape.fill", color: .secondary)
            }
            if showLabels {
                HStack {
                    Text("Messages").frame(maxWidth: .infinity)
                    Text("Camera").frame(maxWidth: .infinity)
                    Text("Music").frame(maxWidth: .infinity)
                    Text("Settings").frame(maxWidth: .infinity)
                }
                .font(.caption2).foregroundStyle(CustomizeColors.muted)
            }
            Text("Icon style: \(selectedIconStyle)")
                .font(.caption).foregroundStyle(CustomizeColors.muted)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [accent.opacity(0.24), CustomizeColors.surface], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 23, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 23).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private func previewIcon(_ symbol: String, color: Color) -> some View {
        Image(systemName: symbol)
            .font(.title2)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: selectedIconStyle == "Rounded" ? 22 : 15))
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).foregroundStyle(.white)
            Text(subtitle).font(.caption).foregroundStyle(CustomizeColors.muted)
        }
    }
}

#Preview {
    CustomizeSettingsView()
}
