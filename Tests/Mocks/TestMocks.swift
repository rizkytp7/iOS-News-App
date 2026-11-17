import Foundation
@testable import CodeNewsIOS

// MARK: - MockAPIClient

final class MockAPIClient: APIClient, @unchecked Sendable {

    var stubbedResult: (any Sendable)?
    var stubbedError: Error?
    private(set) var requestCount = 0

    func request<T: Decodable & Sendable>(_ endpoint: any APIEndpoint) async throws -> T {
        requestCount += 1
        if let error = stubbedError { throw error }
        guard let value = stubbedResult as? T else {
            throw NetworkError.decodingError("Mock type mismatch")
        }
        return value
    }
}

// MARK: - MockNewsRepository

final class MockNewsRepository: NewsRepositoryProtocol, @unchecked Sendable {

    var stubbedSources: [NewsSource] = []
    var stubbedArticles: [Article] = []
    var stubbedTotalResults: Int = 0
    var stubbedError: Error?

    private(set) var fetchSourcesCallCount = 0
    private(set) var fetchArticlesCallCount = 0

    func fetchSources(
        category: String?,
        language: String?,
        country: String?
    ) async throws -> [NewsSource] {
        fetchSourcesCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedSources
    }

    func fetchArticles(
        sourceID: String?,
        query: String?,
        page: Int,
        pageSize: Int
    ) async throws -> (articles: [Article], totalResults: Int) {
        fetchArticlesCallCount += 1
        if let error = stubbedError { throw error }
        return (stubbedArticles, stubbedTotalResults)
    }
}
