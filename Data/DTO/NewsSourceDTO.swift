import Foundation

struct NewsSourceDTO: Decodable, Sendable {
    let id: String?
    let name: String
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?

    // MARK: - Domain mapping

    func toDomain() -> NewsSource {
        NewsSource(
            id: id ?? name.lowercased().replacingOccurrences(of: " ", with: "-"),
            name: name,
            description: description ?? "",
            url: url ?? "",
            category: NewsCategory(rawValue: category ?? "") ?? .general,
            language: language ?? "en",
            country: country ?? "us"
        )
    }
}
