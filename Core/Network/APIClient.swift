import Foundation

/// Protocol that any HTTP client must satisfy.
/// URLSessionAPIClient is the production implementation; tests use MockAPIClient.
protocol APIClient: AnyObject, Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: any APIEndpoint) async throws -> T
}

// MARK: - URLSession production implementation

final class URLSessionAPIClient: APIClient, @unchecked Sendable {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable & Sendable>(_ endpoint: any APIEndpoint) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.makeURLRequest()
        } catch {
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        try validateStatusCode(http.statusCode, data: data)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError.localizedDescription)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Private helpers

    private func validateStatusCode(_ code: Int, data: Data) throws {
        switch code {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            throw NetworkError.serverError(code)
        default:
            throw NetworkError.serverError(code)
        }
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .noInternet
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return .noInternet
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
