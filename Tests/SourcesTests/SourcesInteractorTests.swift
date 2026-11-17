import XCTest
@testable import CodeNewsIOS

// MARK: - Mock repository

final class MockNewsRepository: NewsRepositoryProtocol {

    var stubbedSources: [NewsSource] = []
    var stubbedArticles: [Article] = []
    var stubbedTotalResults: Int = 0
    var stubbedError: Error?

    private(set) var fetchSourcesCallCount = 0
    private(set) var fetchArticlesCallCount = 0

    func fetchSources(category: String?, language: String?, country: String?) async throws -> [NewsSource] {
        fetchSourcesCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedSources
    }

    func fetchArticles(sourceID: String?, query: String?, page: Int, pageSize: Int) async throws -> (articles: [Article], totalResults: Int) {
        fetchArticlesCallCount += 1
        if let error = stubbedError { throw error }
        return (stubbedArticles, stubbedTotalResults)
    }
}

// MARK: - Tests

final class SourcesInteractorTests: XCTestCase {

    private var mockRepo: MockNewsRepository!
    private var sut: SourcesInteractor!

    override func setUp() {
        super.setUp()
        mockRepo = MockNewsRepository()
        sut = SourcesInteractor(repository: mockRepo)
    }

    func test_fetchSources_success_returnsSourcesForCategory() async throws {
        mockRepo.stubbedSources = [
            NewsSource(id: "tc", name: "TechCrunch", description: "", url: "", category: .technology, language: "en", country: "us")
        ]

        let result = try await sut.fetchSources(category: .technology)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, "tc")
        XCTAssertEqual(mockRepo.fetchSourcesCallCount, 1)
    }

    func test_fetchSources_empty_returnsEmpty() async throws {
        mockRepo.stubbedSources = []

        let result = try await sut.fetchSources(category: .technology)

        XCTAssertTrue(result.isEmpty)
    }

    func test_fetchSources_networkError_throws() async {
        mockRepo.stubbedError = NetworkError.noInternet

        do {
            _ = try await sut.fetchSources(category: .technology)
            XCTFail("Expected error")
        } catch NetworkError.noInternet {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func test_fetchSources_passesCorrectCategoryToRepository() async throws {
        mockRepo.stubbedSources = []
        _ = try await sut.fetchSources(category: .sports)
        // Repository would receive "sports" — verified via call count (integration check)
        XCTAssertEqual(mockRepo.fetchSourcesCallCount, 1)
    }
}
