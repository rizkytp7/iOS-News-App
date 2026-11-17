import Foundation

enum ArticleDetailViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
