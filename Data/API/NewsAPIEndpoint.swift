import Foundation

/// All NewsAPI endpoint definitions.
enum NewsAPIEndpoint: APIEndpoint {

    case sources(category: String?, language: String?, country: String?)
    case everything(
        sources: String?,
        query: String?,
        page: Int,
        pageSize: Int,
        language: String?,
        sortBy: String?
    )

    // MARK: - APIEndpoint

    var baseURL: String { APIConfiguration.baseURL }

    var path: String {
        switch self {
        case .sources:
            return "/top-headlines/sources"
        case .everything:
            return "/everything"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .sources(category, language, country):
            return buildSourcesQuery(category: category, language: language, country: country)

        case let .everything(sources, query, page, pageSize, language, sortBy):
            return buildEverythingQuery(
                sources: sources,
                query: query,
                page: page,
                pageSize: pageSize,
                language: language,
                sortBy: sortBy
            )
        }
    }

    var headers: [String: String] { [:] }

    // MARK: - Private query builders

    private func buildSourcesQuery(
        category: String?,
        language: String?,
        country: String?
    ) -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: APIConfiguration.apiKey)
        ]
        if let category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        if let language, !language.isEmpty {
            items.append(URLQueryItem(name: "language", value: language))
        }
        if let country, !country.isEmpty {
            items.append(URLQueryItem(name: "country", value: country))
        }
        return items
    }

    private func buildEverythingQuery(
        sources: String?,
        query: String?,
        page: Int,
        pageSize: Int,
        language: String?,
        sortBy: String?
    ) -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: APIConfiguration.apiKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        if let sources, !sources.isEmpty {
            items.append(URLQueryItem(name: "sources", value: sources))
        }
        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }
        if let language, !language.isEmpty {
            items.append(URLQueryItem(name: "language", value: language))
        }
        if let sortBy, !sortBy.isEmpty {
            items.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        return items
    }
}
