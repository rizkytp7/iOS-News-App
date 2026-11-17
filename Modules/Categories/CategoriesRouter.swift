import SwiftUI

// MARK: - Protocol

protocol CategoriesRouterProtocol: AnyObject {
    func navigateToSources(for category: NewsCategory)
}

// MARK: - Implementation

final class CategoriesRouter: CategoriesRouterProtocol {

    /// The navigation path shared with the root NavigationStack.
    private let navigationPath: NavigationPathStore

    init(navigationPath: NavigationPathStore) {
        self.navigationPath = navigationPath
    }

    func navigateToSources(for category: NewsCategory) {
        navigationPath.push(.sources(category))
    }
}
