import Foundation

// MARK: - Protocol

protocol CategoriesInteractorProtocol: AnyObject {
    func fetchCategories() -> [NewsCategory]
}

// MARK: - Implementation

final class CategoriesInteractor: CategoriesInteractorProtocol {

    /// Categories are static — no network call needed.
    func fetchCategories() -> [NewsCategory] {
        NewsCategory.allCases
    }
}
