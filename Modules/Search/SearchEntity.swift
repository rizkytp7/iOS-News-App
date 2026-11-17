import Foundation

/// Describes what the search screen is searching over.
enum SearchContext: Equatable {
    case sources(NewsCategory)
    case articles(NewsSource)
}

enum SearchViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

struct SearchPaginationState {
    var currentPage: Int = 1
    var pageSize: Int = 20
    var totalResults: Int = 0
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = false

    mutating func reset() {
        currentPage = 1
        totalResults = 0
        isLoadingMore = false
        hasMorePages = false
    }

    mutating func advance(fetchedCount: Int, total: Int) {
        totalResults = total
        currentPage += 1
        hasMorePages = (currentPage - 1) * pageSize < total && fetchedCount == pageSize
    }
}
