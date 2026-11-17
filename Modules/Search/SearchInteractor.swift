import Foundation

// MARK: - Protocol

protocol SearchInteractorProtocol: AnyObject, Sendable {
    func searchSources(category: NewsCategory, query: String) async throws -> [NewsSource]
    func searchArticles(source: NewsSource, query: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int)
}

// MARK: - Implementation

final class SearchInteractor: SearchInteractorProtocol, @unchecked Sendable {

    private let repository: any NewsRepositoryProtocol

    init(repository: any NewsRepositoryProtocol) {
        self.repository = repository
    }

    /// NewsAPI /v2/top-headlines/sources supports a category filter but no free-text query,
    /// so we fetch by category and filter locally.
    func searchSources(category: NewsCategory, query: String) async throws -> [NewsSource] {
        let all = try await repository.fetchSources(
            category: category.rawValue,
            language: nil,
            country: nil
        )
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) ||
            $0.description.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func searchArticles(source: NewsSource, query: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int) {
        try await repository.fetchArticles(
            sourceID: source.id,
            query: query,
            page: page,
            pageSize: pageSize
        )
    }
}
