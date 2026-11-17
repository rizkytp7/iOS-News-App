import XCTest
@testable import CodeNewsIOS

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Tests

final class APIClientTests: XCTestCase {

    private var sut: URLSessionAPIClient!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        sut = URLSessionAPIClient(session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private struct SampleDTO: Codable, Sendable, Equatable {
        let id: Int
        let name: String
    }

    private struct TestEndpoint: APIEndpoint {
        var baseURL: String { "https://example.com" }
        var path: String { "/test" }
        var method: HTTPMethod { .get }
        var queryItems: [URLQueryItem] { [] }
        var headers: [String: String] { [:] }
    }

    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Successful request

    func test_request_successfulResponse_decodesDTO() async throws {
        let expected = SampleDTO(id: 1, name: "News")
        let data = try JSONEncoder().encode(expected)

        MockURLProtocol.requestHandler = { [weak self] _ in
            guard let self else { throw URLError(.unknown) }
            return (self.makeResponse(statusCode: 200), data)
        }

        let result: SampleDTO = try await sut.request(TestEndpoint())
        XCTAssertEqual(result, expected)
    }

    // MARK: - HTTP 401

    func test_request_401_throwsUnauthorized() async {
        MockURLProtocol.requestHandler = { [weak self] _ in
            guard let self else { throw URLError(.unknown) }
            return (self.makeResponse(statusCode: 401), Data())
        }

        do {
            let _: SampleDTO = try await sut.request(TestEndpoint())
            XCTFail("Expected NetworkError.unauthorized")
        } catch NetworkError.unauthorized {
            // pass
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - HTTP 429

    func test_request_429_throwsRateLimited() async {
        MockURLProtocol.requestHandler = { [weak self] _ in
            guard let self else { throw URLError(.unknown) }
            return (self.makeResponse(statusCode: 429), Data())
        }

        do {
            let _: SampleDTO = try await sut.request(TestEndpoint())
            XCTFail("Expected NetworkError.rateLimited")
        } catch NetworkError.rateLimited {
            // pass
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Decoding failure

    func test_request_malformedJSON_throwsDecodingError() async {
        MockURLProtocol.requestHandler = { [weak self] _ in
            guard let self else { throw URLError(.unknown) }
            return (self.makeResponse(statusCode: 200), Data("not_json".utf8))
        }

        do {
            let _: SampleDTO = try await sut.request(TestEndpoint())
            XCTFail("Expected NetworkError.decodingError")
        } catch NetworkError.decodingError {
            // pass
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - No internet

    func test_request_noInternet_throwsNoInternet() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: SampleDTO = try await sut.request(TestEndpoint())
            XCTFail("Expected NetworkError.noInternet")
        } catch NetworkError.noInternet {
            // pass
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - HTTP 500

    func test_request_500_throwsServerError() async {
        MockURLProtocol.requestHandler = { [weak self] _ in
            guard let self else { throw URLError(.unknown) }
            return (self.makeResponse(statusCode: 500), Data())
        }

        do {
            let _: SampleDTO = try await sut.request(TestEndpoint())
            XCTFail("Expected NetworkError.serverError(500)")
        } catch NetworkError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
