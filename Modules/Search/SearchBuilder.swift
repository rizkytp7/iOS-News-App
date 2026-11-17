import SwiftUI

enum SearchBuilder {

    @MainActor static func build(
        context: SearchContext,
        repository: any NewsRepositoryProtocol,
        navigationPath: NavigationPathStore
    ) -> SearchView {
        let router = SearchRouter(navigationPath: navigationPath)
        let interactor = SearchInteractor(repository: repository)
        let presenter = SearchPresenter(
            context: context,
            interactor: interactor,
            router: router
        )
        return SearchView(presenter: presenter)
    }
}
