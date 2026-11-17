import SwiftUI

// MARK: - Protocol

protocol ArticlesRouterProtocol: AnyObject {
    func navigateToArticleDetail(_ article: Article)
    func navigateToSearch(source: NewsSource)
}

// MARK: - Implementation

final class ArticlesRouter: ArticlesRouterProtocol {

    private let navigationPath: NavigationPathStore

    init(navigationPath: NavigationPathStore) {
        self.navigationPath = navigationPath
    }

    func navigateToArticleDetail(_ article: Article) {
        navigationPath.push(.articleDetail(article))
    }

    func navigateToSearch(source: NewsSource) {
        navigationPath.push(.search(.articles(source)))
    }
}
