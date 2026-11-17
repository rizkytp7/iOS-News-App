import Foundation

// The Categories module's entity layer is intentionally thin because
// NewsCategory is a static enum defined in the Domain layer.
// The Interactor does not hit the network; it returns the fixed list immediately.

enum CategoriesViewState: Equatable {
    case idle
    case loaded([NewsCategory])
}
