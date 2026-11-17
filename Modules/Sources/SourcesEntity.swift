import Foundation

/// Pagination state for the Sources screen.
/// NewsAPI /v2/top-headlines/sources returns all sources in one call,
/// so we paginate the full list client-side.
struct SourcesPaginationState {
    var allSources: [NewsSource] = []      // full server result
    var displayedSources: [NewsSource] = [] // current page slice
    var currentPage: Int = 1
    let pageSize: Int = 20
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = false

    mutating func reset() {
        allSources = []
        displayedSources = []
        currentPage = 1
        isLoadingMore = false
        hasMorePages = false
    }

    mutating func loadNextPage() {
        guard hasMorePages, !isLoadingMore else { return }
        isLoadingMore = true
        let start = currentPage * pageSize
        let end = min(start + pageSize, allSources.count)
        guard start < end else {
            hasMorePages = false
            isLoadingMore = false
            return
        }
        displayedSources.append(contentsOf: allSources[start..<end])
        currentPage += 1
        hasMorePages = end < allSources.count
        isLoadingMore = false
    }
}

enum SourcesViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
