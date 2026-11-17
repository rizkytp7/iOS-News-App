import SwiftUI

struct SearchView: View {

    @State var presenter: SearchPresenter

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $presenter.searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            contentView
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.viewDidAppear() }
        .accessibilityIdentifier("search_screen")
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch presenter.viewState {
        case .idle:
            idlePrompt
        case .loading:
            LoadingView()
        case .error(let message):
            ErrorView(message: message) { presenter.retry() }
        case .empty:
            EmptyStateView(
                title: "No Results",
                message: "\(presenter.searchText)",
                systemImage: "magnifyingglass"
            )
        case .loaded:
            switch presenter.context {
            case .sources:
                sourceResults
            case .articles:
                articleResults
            }
        }
    }

    private var idlePrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Start typing to search")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Source results

    private var sourceResults: some View {
        List {
            ForEach(presenter.sources) { source in
                SearchSourceRowView(source: source) {
                    presenter.didSelectSource(source)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .accessibilityIdentifier("source_item")
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Article results

    private var articleResults: some View {
        List {
            ForEach(presenter.articles) { article in
                SearchArticleRowView(article: article) {
                    presenter.didSelectArticle(article)
                }
                .onAppear { presenter.loadMoreIfNeeded(articleID: article.id) }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .accessibilityIdentifier("article_item")
            }

            if presenter.isLoadingMore {
                PaginationLoadingView()
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Navigation title

    private var navigationTitle: String {
        switch presenter.context {
        case .sources(let category): return "Search \(category.displayName)"
        case .articles(let source):  return "Search \(source.name)"
        }
    }
}

// MARK: - Row sub-views

private struct SearchSourceRowView: View {
    let source: NewsSource
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(source.name).font(.headline)
                if !source.description.isEmpty {
                    Text(source.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    Label(source.country.uppercased(), systemImage: "globe")
                    Label(source.language.uppercased(), systemImage: "textformat")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(14)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

private struct SearchArticleRowView: View {
    let article: Article
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImageView(urlString: article.imageURL, aspectRatio: 1, cornerRadius: 8)
                    .frame(width: 80, height: 80)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.subheadline.bold())
                        .lineLimit(3)
                    if let date = article.publishedAt {
                        Text(date.relativeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
