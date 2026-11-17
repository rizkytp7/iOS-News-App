import SwiftUI

enum ArticlesBuilder {

    @MainActor static func build(
        source: NewsSource,
        repository: any NewsRepositoryProtocol,
        navigationPath: NavigationPathStore
    ) -> ArticlesView {
        let router = ArticlesRouter(navigationPath: navigationPath)
        let interactor = ArticlesInteractor(repository: repository)
        let presenter = ArticlesPresenter(
            source: source,
            interactor: interactor,
            router: router
        )
        return ArticlesView(presenter: presenter, source: source)
    }
}
