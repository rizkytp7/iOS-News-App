import SwiftUI

struct CategoriesView: View {

    @State var presenter: CategoriesPresenter

    // MARK: - Layout constants

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(presenter.categories) { category in
                    CategoryCardView(category: category) {
                        presenter.didSelectCategory(category)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("News Categories")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { presenter.viewDidAppear() }
        .accessibilityIdentifier("categories_screen")
    }
}

// MARK: - Category card

private struct CategoryCardView: View {
    let category: NewsCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(category.accentColor)

                Text(category.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(category.accessibilityIdentifier)
        .accessibilityLabel(category.displayName)
        .accessibilityHint("View news sources for \(category.displayName)")
    }
}
