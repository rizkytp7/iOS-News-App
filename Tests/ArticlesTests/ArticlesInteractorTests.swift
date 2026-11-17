import XCTest
@testable import CodeNewsIOS

final class ArticlesInteractorTests: XCTestCase {

    private var mockRepo: MockNewsRepository!
    private var sut: ArticlesInteractor!

    override func setUp() {
        super.setUp()
        mockRepo = MockNewsRepository()
        sut = ArticlesInteractor(repository: mockRepo)
    }

    // MARK: - Fetch articles

    func test_fetchArticles_success_returnsArticles() async throws {
        let article = Article(
            id: "https://example.com/1", title: "Title", description: nil,
            url: "https://example.com/1", imageURL: nil, author: nil,
            publishedAt: nil, sourceName: "Source"
        )
        mockRepo.stubbedArticles = [article]
        mockRepo.stubbedTotalResults = 1

        let result = try await sut.fetchArticles(sourceID: "source-id", page: 1, pageSize: 20)

        XCTAssertEqual(result.articles.count, 1)
        XCTAssertEqual(result.totalResults, 1)
    }

    func test_fetchArticles_empty_returnsEmpty() async throws {
        mockRepo.stubbedArticles = []
        mockRepo.stubbedTotalResults = 0

        let result = try await sut.fetchArticles(sourceID: "source-id", page: 1, pageSize: 20)

        XCTAssertTrue(result.articles.isEmpty)
        XCTAssertEqual(result.totalResults, 0)
    }

    func test_fetchArticles_error_throws() async {
        mockRepo.stubbedError = NetworkError.serverError(500)

        do {
            _ = try await sut.fetchArticles(sourceID: "source-id", page: 1, pageSize: 20)
            XCTFail("Expected error")
        } catch NetworkError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func test_fetchArticles_paginationPage2_callsRepositoryOnce() async throws {
        mockRepo.stubbedArticles = []
        mockRepo.stubbedTotalResults = 0

        _ = try await sut.fetchArticles(sourceID: "source-id", page: 2, pageSize: 20)

        XCTAssertEqual(mockRepo.fetchArticlesCallCount, 1)
    }

    // MARK: - Search articles

    func test_searchArticles_returnsMatchingArticles() async throws {
        let article = Article(
            id: "https://example.com/swift6", title: "Swift 6 Released", description: nil,
            url: "https://example.com/swift6", imageURL: nil, author: nil,
            publishedAt: nil, sourceName: "TechCrunch"
        )
        mockRepo.stubbedArticles = [article]
        mockRepo.stubbedTotalResults = 1

        let result = try await sut.searchArticles(query: "swift", page: 1, pageSize: 20)

        XCTAssertEqual(result.articles.count, 1)
    }

    func test_searchArticles_emptyQuery_callsRepository() async throws {
        mockRepo.stubbedArticles = []
        mockRepo.stubbedTotalResults = 0

        let result = try await sut.searchArticles(query: "", page: 1, pageSize: 20)

        XCTAssertTrue(result.articles.isEmpty)
        XCTAssertEqual(mockRepo.fetchArticlesCallCount, 1)
    }
}
