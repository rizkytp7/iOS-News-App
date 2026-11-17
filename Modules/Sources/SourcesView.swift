import SwiftUI

struct SourcesView: View {

    @State var presenter: SourcesPresenter
    let category: NewsCategory

    var body: some View {
        Group {
            switch presenter.viewState {
            case .idle, .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message) { presenter.retry() }
            case .empty:
                EmptyStateView(
                    title: "No Sources Found",
                    message: "There are no sources available for \(category.displayName).",
                    systemImage: "newspaper",
                    actionTitle: "Retry",
                    onAction: { presenter.retry() }
                )
            case .loaded:
                sourcesList
            }
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.didTapSearch()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search sources")
            }
        }
        .onAppear { presenter.viewDidAppear() }
        .accessibilityIdentifier("sources_screen")
    }

    // MARK: - Sources list

    private var sourcesList: some View {
        List {
            ForEach(presenter.displayedSources) { source in
                SourceRowView(source: source)
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.didSelectSource(source) }
                    .onAppear { presenter.loadMoreIfNeeded(currentItem: source) }
                    .accessibilityIdentifier("source_item")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }

            if presenter.isLoadingMore {
                PaginationLoadingView()
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier("source_list")
    }
}

// MARK: - Source row card

private struct SourceRowView: View {
    let source: NewsSource

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(source.name)
                .font(.headline)
                .foregroundStyle(.primary)

            if !source.description.isEmpty {
                Text(source.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack(spacing: 12) {
                Label(source.country.uppercased(), systemImage: "globe")
                Label(source.language.uppercased(), systemImage: "textformat")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .cardStyle()
    }
}
