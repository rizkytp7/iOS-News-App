import Foundation

struct ArticleDTO: Decodable, Sendable {
    let source: ArticleSourceDTO?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    // MARK: - Domain mapping

    func toDomain() -> Article? {
        // A title and URL are the minimum viable article.
        guard
            let title, !title.isEmpty,
            let url, !url.isEmpty
        else { return nil }

        return Article(
            id: url,
            title: title,
            description: description?.isEmpty == false ? description : nil,
            url: url,
            imageURL: urlToImage,
            author: author?.isEmpty == false ? author : nil,
            publishedAt: publishedAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            sourceName: source?.name ?? "Unknown"
        )
    }
}

struct ArticleSourceDTO: Decodable, Sendable {
    let id: String?
    let name: String?
}
