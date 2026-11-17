import Foundation

// MARK: - Protocol

protocol ArticlesInteractorProtocol: AnyObject, Sendable {
    func fetchArticles(sourceID: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int)
    func searchArticles(query: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int)
}

// MARK: - Implementation

final class ArticlesInteractor: ArticlesInteractorProtocol, @unchecked Sendable {

    private let repository: any NewsRepositoryProtocol

    init(repository: any NewsRepositoryProtocol) {
        self.repository = repository
    }

    func fetchArticles(sourceID: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int) {
        try await repository.fetchArticles(
            sourceID: sourceID,
            query: nil,
            page: page,
            pageSize: pageSize
        )
    }

    func searchArticles(query: String, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int) {
        try await repository.fetchArticles(
            sourceID: nil,
            query: query,
            page: page,
            pageSize: pageSize
        )
    }
}
