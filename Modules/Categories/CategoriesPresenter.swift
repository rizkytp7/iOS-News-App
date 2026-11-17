import Foundation
import Observation

// MARK: - Protocol

protocol CategoriesPresenterProtocol: AnyObject {
    var categories: [NewsCategory] { get }
    func viewDidAppear()
    func didSelectCategory(_ category: NewsCategory)
}

// MARK: - Implementation

@Observable
@MainActor
final class CategoriesPresenter: @MainActor CategoriesPresenterProtocol {

    // MARK: - Published state

    private(set) var categories: [NewsCategory] = []

    // MARK: - Dependencies

    private let interactor: any CategoriesInteractorProtocol
    private let router: any CategoriesRouterProtocol

    init(
        interactor: any CategoriesInteractorProtocol,
        router: any CategoriesRouterProtocol
    ) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - CategoriesPresenterProtocol

    func viewDidAppear() {
        categories = interactor.fetchCategories()
    }

    func didSelectCategory(_ category: NewsCategory) {
        router.navigateToSources(for: category)
    }
}
