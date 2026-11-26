import Foundation
import Combine

@MainActor
final class CompatibilityCatalogService: ObservableObject {
    @Published private(set) var entries: [JailbreakCompatibilityEntry] = []
    @Published private(set) var status = "Catalog has not been refreshed yet."
    @Published private(set) var isLoading = false
    @Published private(set) var lastUpdated: String?

    private let catalogURL = URL(string: "https://raw.githubusercontent.com/itamarnintendo04-arch/TweaksBar/main/iOS/TweaksSettings/compatibility-catalog.json")!

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            var request = URLRequest(url: catalogURL)
            request.timeoutInterval = 15
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                throw CatalogError.invalidResponse
            }
            guard data.count <= 512_000 else {
                throw CatalogError.responseTooLarge
            }

            let document = try JSONDecoder().decode(CompatibilityCatalogDocument.self, from: data)
            guard document.schemaVersion == 1 else {
                throw CatalogError.unsupportedSchema
            }

            // Only HTTPS source links are accepted for display in the app.
            entries = document.entries.map { entry in
                var safeEntry = entry
                if let sourceURL = entry.sourceURL, sourceURL.scheme?.lowercased() != "https" {
                    safeEntry.sourceURL = nil
                }
                return safeEntry
            }
            lastUpdated = document.generatedAt
            status = "Catalog updated successfully."
        } catch {
            status = "Could not refresh catalog. Showing the last successfully loaded data."
        }
    }
}

private enum CatalogError: Error {
    case invalidResponse
    case responseTooLarge
    case unsupportedSchema
}

private struct CompatibilityCatalogDocument: Decodable {
    let schemaVersion: Int
    let generatedAt: String
    let entries: [JailbreakCompatibilityEntry]
}
