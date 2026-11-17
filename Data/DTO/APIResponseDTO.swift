import Foundation

/// Top-level wrapper for /v2/top-headlines/sources
struct SourcesResponseDTO: Decodable, Sendable {
    let status: String
    let sources: [NewsSourceDTO]
}

/// Top-level wrapper for /v2/everything
struct ArticlesResponseDTO: Decodable, Sendable {
    let status: String
    let totalResults: Int
    let articles: [ArticleDTO]
}
