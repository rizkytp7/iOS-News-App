import SwiftUI

// MARK: - Protocol

protocol SourcesRouterProtocol: AnyObject {
    func navigateToArticles(for source: NewsSource)
    func navigateToSearch(category: NewsCategory)
}

// MARK: - Implementation

final class SourcesRouter: SourcesRouterProtocol {

    private let navigationPath: NavigationPathStore

    init(navigationPath: NavigationPathStore) {
        self.navigationPath = navigationPath
    }

    func navigateToArticles(for source: NewsSource) {
        navigationPath.push(.articles(source))
    }

    func navigateToSearch(category: NewsCategory) {
        navigationPath.push(.search(.sources(category)))
    }
}
