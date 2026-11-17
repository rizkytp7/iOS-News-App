import SwiftUI

/// Assembles the Categories VIPER module.
enum CategoriesBuilder {

    @MainActor static func build(navigationPath: NavigationPathStore) -> CategoriesView {
        let router = CategoriesRouter(navigationPath: navigationPath)
        let interactor = CategoriesInteractor()
        let presenter = CategoriesPresenter(interactor: interactor, router: router)
        return CategoriesView(presenter: presenter)
    }
}
