import Foundation

final class NewsRepositoryImpl: NewsRepositoryProtocol, @unchecked Sendable {

    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Sources

    func fetchSources(
        category: String?,
        language: String?,
        country: String?
    ) async throws -> [NewsSource] {
        let endpoint = NewsAPIEndpoint.sources(
            category: category,
            language: language,
            country: country
        )
        let response: SourcesResponseDTO = try await apiClient.request(endpoint)
        return response.sources.map { $0.toDomain() }
    }

    // MARK: - Articles

    func fetchArticles(
        sourceID: String?,
        query: String?,
        page: Int,
        pageSize: Int
    ) async throws -> (articles: [Article], totalResults: Int) {
        let endpoint = NewsAPIEndpoint.everything(
            sources: sourceID,
            query: query,
            page: page,
            pageSize: pageSize,
            language: nil,
            sortBy: "publishedAt"
        )
        let response: ArticlesResponseDTO = try await apiClient.request(endpoint)
        let articles = response.articles.compactMap { $0.toDomain() }
        return (articles, response.totalResults)
    }
}
