import SwiftUI

struct PosterBoardSettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PosterBoard").font(.largeTitle.bold()).foregroundStyle(.white)
                        Text("A dedicated space for your wallpaper and Lock Screen setup.")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.58))
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(LinearGradient(colors: [Color(red: 0.18, green: 0.28, blue: 0.55), Color(red: 0.10, green: 0.12, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 13) {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 38, weight: .light))
                                .foregroundStyle(.white)
                            Text("PosterBoard Studio")
                                .font(.title2.bold()).foregroundStyle(.white)
                            Text("Your customization workspace")
                                .font(.caption).foregroundStyle(.white.opacity(0.68))
                            HStack(spacing: 7) {
                                Image(systemName: "lock.fill")
                                Text("Integration not verified")
                            }
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.black.opacity(0.22), in: Capsule())
                        }
                        .padding(28)
                    }
                    .frame(maxWidth: .infinity).frame(height: 220)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("INTEGRATION STATUS").font(.caption2.bold()).tracking(1.1).foregroundStyle(Color.cyan)
                        statusRow("Device compatibility", value: "Not verified", icon: "iphone", color: .orange)
                        Divider().overlay(.white.opacity(0.08))
                        statusRow("TweaksBar engine", value: "Not connected", icon: "cpu", color: .orange)
                        Divider().overlay(.white.opacity(0.08))
                        statusRow("Changes applied", value: "None", icon: "checkmark.circle", color: .secondary)
                    }
                    .padding(17)
                    .background(Color(red: 0.075, green: 0.105, blue: 0.16), in: RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 8) {
                        Label("What will be available here", systemImage: "sparkles")
                            .font(.headline).foregroundStyle(.white)
                        Text("PosterBoard options, previews, and supported customization controls will appear here after a verified integration is connected for this iOS version.")
                            .font(.caption).foregroundStyle(.white.opacity(0.58))
                    }
                    .padding(17)
                    .background(Color(red: 0.075, green: 0.105, blue: 0.16), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
            }
            .background(Color(red: 0.035, green: 0.055, blue: 0.095).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func statusRow(_ title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.subheadline).foregroundStyle(color).frame(width: 25)
            Text(title).font(.subheadline).foregroundStyle(.white)
            Spacer()
            Text(value).font(.caption).foregroundStyle(color)
        }
    }
}

#Preview {
    PosterBoardSettingsView()
}
