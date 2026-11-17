import XCTest
@testable import CodeNewsIOS

final class SearchInteractorTests: XCTestCase {

    private var mockRepo: MockNewsRepository!
    private var sut: SearchInteractor!

    private let techCategory = NewsCategory.technology
    private lazy var techSource = NewsSource(
        id: "techcrunch", name: "TechCrunch", description: "Tech news",
        url: "https://techcrunch.com", category: .technology, language: "en", country: "us"
    )

    override func setUp() {
        super.setUp()
        mockRepo = MockNewsRepository()
        sut = SearchInteractor(repository: mockRepo)
    }

    // MARK: - Source search

    func test_searchSources_emptyQuery_returnsAll() async throws {
        mockRepo.stubbedSources = [techSource]

        let results = try await sut.searchSources(category: techCategory, query: "")

        XCTAssertEqual(results.count, 1)
    }

    func test_searchSources_matchingQuery_returnsFiltered() async throws {
        let other = NewsSource(
            id: "bbc", name: "BBC News", description: "World news",
            url: "https://bbc.com", category: .general, language: "en", country: "gb"
        )
        mockRepo.stubbedSources = [techSource, other]

        let results = try await sut.searchSources(category: techCategory, query: "tech")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, "techcrunch")
    }

    func test_searchSources_noMatch_returnsEmpty() async throws {
        mockRepo.stubbedSources = [techSource]

        let results = try await sut.searchSources(category: techCategory, query: "zzz-no-match")

        XCTAssertTrue(results.isEmpty)
    }

    func test_searchSources_caseInsensitive_matches() async throws {
        mockRepo.stubbedSources = [techSource]

        let results = try await sut.searchSources(category: techCategory, query: "TECHCRUNCH")

        XCTAssertEqual(results.count, 1)
    }

    func test_searchSources_networkError_throws() async {
        mockRepo.stubbedError = NetworkError.noInternet

        do {
            _ = try await sut.searchSources(category: techCategory, query: "tech")
            XCTFail("Expected error")
        } catch NetworkError.noInternet {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - Article search

    func test_searchArticles_success_returnsResults() async throws {
        let article = Article(
            id: "https://example.com/1", title: "Swift News", description: nil,
            url: "https://example.com/1", imageURL: nil, author: nil,
            publishedAt: nil, sourceName: "TechCrunch"
        )
        mockRepo.stubbedArticles = [article]
        mockRepo.stubbedTotalResults = 1

        let result = try await sut.searchArticles(source: techSource, query: "swift", page: 1, pageSize: 20)

        XCTAssertEqual(result.articles.count, 1)
        XCTAssertEqual(result.totalResults, 1)
    }

    func test_searchArticles_error_throws() async {
        mockRepo.stubbedError = NetworkError.rateLimited

        do {
            _ = try await sut.searchArticles(source: techSource, query: "swift", page: 1, pageSize: 20)
            XCTFail("Expected error")
        } catch NetworkError.rateLimited {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func test_searchArticles_emptyResults_returnsEmpty() async throws {
        mockRepo.stubbedArticles = []
        mockRepo.stubbedTotalResults = 0

        let result = try await sut.searchArticles(source: techSource, query: "noresult", page: 1, pageSize: 20)

        XCTAssertTrue(result.articles.isEmpty)
    }
}
