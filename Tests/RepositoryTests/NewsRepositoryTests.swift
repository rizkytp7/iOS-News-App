import XCTest
@testable import CodeNewsIOS

final class NewsRepositoryTests: XCTestCase {

    private var mockClient: MockAPIClient!
    private var sut: NewsRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient()
        sut = NewsRepositoryImpl(apiClient: mockClient)
    }

    // MARK: - Sources

    func test_fetchSources_success_returnsDomainModels() async throws {
        let dto = SourcesResponseDTO(
            status: "ok",
            sources: [
                NewsSourceDTO(
                    id: "techcrunch",
                    name: "TechCrunch",
                    description: "Tech news",
                    url: "https://techcrunch.com",
                    category: "technology",
                    language: "en",
                    country: "us"
                )
            ]
        )
        mockClient.stubbedResult = dto

        let sources = try await sut.fetchSources(category: "technology", language: nil, country: nil)

        XCTAssertEqual(sources.count, 1)
        XCTAssertEqual(sources[0].id, "techcrunch")
        XCTAssertEqual(sources[0].name, "TechCrunch")
        XCTAssertEqual(sources[0].category, .technology)
    }

    func test_fetchSources_networkError_propagates() async {
        mockClient.stubbedError = NetworkError.noInternet

        do {
            _ = try await sut.fetchSources(category: nil, language: nil, country: nil)
            XCTFail("Expected error")
        } catch NetworkError.noInternet {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - Articles

    func test_fetchArticles_success_returnsDomainModels() async throws {
        let dto = ArticlesResponseDTO(
            status: "ok",
            totalResults: 1,
            articles: [
                ArticleDTO(
                    source: ArticleSourceDTO(id: "techcrunch", name: "TechCrunch"),
                    author: "John",
                    title: "Swift 6 Released",
                    description: "Major new features",
                    url: "https://techcrunch.com/swift6",
                    urlToImage: nil,
                    publishedAt: "2024-01-01T00:00:00Z",
                    content: nil
                )
            ]
        )
        mockClient.stubbedResult = dto

        let result = try await sut.fetchArticles(sourceID: "techcrunch", query: nil, page: 1, pageSize: 20)

        XCTAssertEqual(result.articles.count, 1)
        XCTAssertEqual(result.articles[0].title, "Swift 6 Released")
        XCTAssertEqual(result.totalResults, 1)
    }

    func test_fetchArticles_emptyResponse_returnsEmpty() async throws {
        let dto = ArticlesResponseDTO(status: "ok", totalResults: 0, articles: [])
        mockClient.stubbedResult = dto

        let result = try await sut.fetchArticles(sourceID: "techcrunch", query: nil, page: 1, pageSize: 20)

        XCTAssertTrue(result.articles.isEmpty)
        XCTAssertEqual(result.totalResults, 0)
    }

    func test_fetchArticles_articlesMissingTitle_filtered() async throws {
        let dto = ArticlesResponseDTO(
            status: "ok",
            totalResults: 2,
            articles: [
                ArticleDTO(
                    source: nil,
                    author: nil,
                    title: nil,
                    description: nil,
                    url: "https://example.com/1",
                    urlToImage: nil,
                    publishedAt: nil,
                    content: nil
                ),
                ArticleDTO(
                    source: ArticleSourceDTO(id: nil, name: "Source"),
                    author: nil,
                    title: "Valid Title",
                    description: nil,
                    url: "https://example.com/2",
                    urlToImage: nil,
                    publishedAt: nil,
                    content: nil
                )
            ]
        )
        mockClient.stubbedResult = dto

        let result = try await sut.fetchArticles(sourceID: nil, query: "swift", page: 1, pageSize: 20)

        // Article without title must be filtered out by toDomain()
        XCTAssertEqual(result.articles.count, 1)
        XCTAssertEqual(result.articles[0].title, "Valid Title")
    }
}
