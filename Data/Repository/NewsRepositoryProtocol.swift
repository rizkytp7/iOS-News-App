import Foundation

/// The single data-access interface shared by all VIPER Interactors.
/// Inject a mock that conforms to this protocol in unit tests.
protocol NewsRepositoryProtocol: Sendable {

    /// Fetch news sources, optionally filtered by category.
    /// NewsAPI /v2/top-headlines/sources does not paginate, so we do
    /// client-side pagination in the Interactor.
    func fetchSources(
        category: String?,
        language: String?,
        country: String?
    ) async throws -> [NewsSource]

    /// Fetch articles from /v2/everything.
    func fetchArticles(
        sourceID: String?,
        query: String?,
        page: Int,
        pageSize: Int
    ) async throws -> (articles: [Article], totalResults: Int)
}
