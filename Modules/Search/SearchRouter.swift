import SwiftUI

// MARK: - Protocol

protocol SearchRouterProtocol: AnyObject {
    func navigateToArticles(for source: NewsSource)
    func navigateToArticleDetail(_ article: Article)
}

// MARK: - Implementation

final class SearchRouter: SearchRouterProtocol {

    private let navigationPath: NavigationPathStore

    init(navigationPath: NavigationPathStore) {
        self.navigationPath = navigationPath
    }

    func navigateToArticles(for source: NewsSource) {
        navigationPath.push(.articles(source))
    }

    func navigateToArticleDetail(_ article: Article) {
        navigationPath.push(.articleDetail(article))
    }
}
