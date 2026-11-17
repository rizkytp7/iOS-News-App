import SwiftUI

enum SourcesBuilder {

    @MainActor static func build(
        category: NewsCategory,
        repository: any NewsRepositoryProtocol,
        navigationPath: NavigationPathStore
    ) -> SourcesView {
        let router = SourcesRouter(navigationPath: navigationPath)
        let interactor = SourcesInteractor(repository: repository)
        let presenter = SourcesPresenter(
            category: category,
            interactor: interactor,
            router: router
        )
        return SourcesView(presenter: presenter, category: category)
    }
}
