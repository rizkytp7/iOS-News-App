import SwiftUI

// MARK: - Navigation destinations

/// Every screen in the app is a case here so the NavigationStack can route to it.
enum AppDestination: Hashable {
    case sources(NewsCategory)
    case articles(NewsSource)
    case articleDetail(Article)
    case search(SearchContext)
}

// Make SearchContext Hashable so it can be used in AppDestination.
extension SearchContext: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .sources(let category):
            hasher.combine(0)
            hasher.combine(category.rawValue)
        case .articles(let source):
            hasher.combine(1)
            hasher.combine(source.id)
        }
    }
}

// Make NewsSource Hashable
extension NewsSource: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Make Article Hashable
extension Article: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - NavigationPathStore

/// A shared, observable navigation path injected into every Router.
@Observable
final class NavigationPathStore {

    var path: [AppDestination] = []

    func push(_ destination: AppDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
