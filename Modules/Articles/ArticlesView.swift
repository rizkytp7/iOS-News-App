import SwiftUI

struct ArticlesView: View {

    @State var presenter: ArticlesPresenter
    let source: NewsSource

    var body: some View {
        Group {
            switch presenter.viewState {
            case .idle, .loading:
                LoadingView()
            case .error(let message):
                ErrorView(message: message) { presenter.retry() }
            case .empty:
                EmptyStateView(
                    title: "No Articles",
                    message: "No articles found for \(source.name).",
                    systemImage: "doc.text",
                    actionTitle: "Retry",
                    onAction: { presenter.retry() }
                )
            case .loaded:
                articlesList
            }
        }
        .navigationTitle(source.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { presenter.didTapSearch() } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search articles")
            }
        }
        .onAppear { presenter.viewDidAppear() }
        .accessibilityIdentifier("articles_screen")
    }

    // MARK: - Articles list

    private var articlesList: some View {
        List {
            ForEach(presenter.articles) { article in
                ArticleCardView(article: article)
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.didSelectArticle(article) }
                    .onAppear { presenter.loadMoreIfNeeded(currentItem: article) }
                    .accessibilityIdentifier("article_item")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if presenter.isLoadingMore {
                PaginationLoadingView()
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { await presenter.refresh() }
        .accessibilityIdentifier("article_list")
    }
}

// MARK: - Article card

private struct ArticleCardView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image
            AsyncImageView(urlString: article.imageURL, aspectRatio: 16/9, cornerRadius: 12)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)

                // Description (optional)
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Meta row
                HStack(spacing: 6) {
                    Text(article.sourceName)
                        .font(.caption.bold())
                        .foregroundStyle(.black)

                    Text("·")
                        .foregroundStyle(.secondary)

                    if let date = article.publishedAt {
                        Text(date.relativeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let author = article.author {
                        Text(author)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)
        }
        .cardStyle()
    }
}
