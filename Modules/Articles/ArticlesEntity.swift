import Foundation

struct ArticlesPaginationState {
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

enum ArticlesViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
