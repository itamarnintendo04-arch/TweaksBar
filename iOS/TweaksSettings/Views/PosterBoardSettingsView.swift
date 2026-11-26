import SwiftUI

struct PosterBoardSettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 30))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PosterBoard")
                                .font(.headline)
                            Text("Integration not verified")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Settings") {
                    LabeledContent("Device compatibility", value: "Not verified")
                    LabeledContent("Tweak engine", value: "Not connected")
                    LabeledContent("Changes applied", value: "None")
                }

                Section {
                    Text("This page is the mobile control-center foundation. Applying wallpapers or changing system behavior will be enabled only after TweaksBar has a verified PosterBoard integration for the installed iOS version.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("PosterBoard")
        }
    }
}

#Preview {
    PosterBoardSettingsView()
}
