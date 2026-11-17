import Foundation
import Observation

// MARK: - Protocol

protocol ArticlesPresenterProtocol: AnyObject {
    var viewState: ArticlesViewState { get }
    var articles: [Article] { get }
    var isLoadingMore: Bool { get }
    var hasMorePages: Bool { get }
    func viewDidAppear()
    func retry()
    func refresh() async
    func loadMoreIfNeeded(currentItem: Article)
    func didSelectArticle(_ article: Article)
    func didTapSearch()
}

// MARK: - Implementation

@Observable
@MainActor
final class ArticlesPresenter: @MainActor ArticlesPresenterProtocol {

    // MARK: - State

    private(set) var viewState: ArticlesViewState = .idle
    private(set) var articles: [Article] = []
    private(set) var isLoadingMore: Bool = false
    private(set) var hasMorePages: Bool = false

    // MARK: - Private

    private var pagination = ArticlesPaginationState()
    private let source: NewsSource
    private let interactor: any ArticlesInteractorProtocol
    private let router: any ArticlesRouterProtocol
    private var loadTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?

    init(
        source: NewsSource,
        interactor: any ArticlesInteractorProtocol,
        router: any ArticlesRouterProtocol
    ) {
        self.source = source
        self.interactor = interactor
        self.router = router
    }

    // MARK: - ArticlesPresenterProtocol

    func viewDidAppear() {
        guard viewState == .idle else { return }
        load(reset: true)
    }

    func retry() {
        load(reset: true)
    }

    /// Called by SwiftUI's `.refreshable`. Awaits the load task so the spinner
    /// dismisses only after the fetch completes.
    func refresh() async {
        loadTask?.cancel()
        loadMoreTask?.cancel()
        await performLoad(reset: true)
    }

    func loadMoreIfNeeded(currentItem: Article) {
        guard
            hasMorePages,
            !isLoadingMore,
            let lastID = articles.last?.id,
            currentItem.id == lastID
        else { return }
        loadMore()
    }

    func didSelectArticle(_ article: Article) {
        router.navigateToArticleDetail(article)
    }

    func didTapSearch() {
        router.navigateToSearch(source: source)
    }

    // MARK: - Private

    private func load(reset: Bool) {
        loadTask?.cancel()
        loadMoreTask?.cancel()
        loadTask = Task { await self.performLoad(reset: reset) }
    }

    private func performLoad(reset: Bool) async {
        if reset {
            pagination.reset()
            articles = []
        }
        viewState = .loading
        do {
            let result = try await interactor.fetchArticles(
                sourceID: source.id,
                page: 1,
                pageSize: pagination.pageSize
            )
            articles = result.articles
            pagination.reset()
            pagination.advance(fetchedCount: result.articles.count, total: result.totalResults)
            hasMorePages = pagination.hasMorePages
            viewState = result.articles.isEmpty ? .empty : .loaded
        } catch {
            guard !Task.isCancelled else { return }
            viewState = .error(mapError(error))
        }
    }

    private func loadMore() {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        let page = pagination.currentPage

        loadMoreTask = Task {
            defer { self.isLoadingMore = false }
            do {
                let result = try await self.interactor.fetchArticles(
                    sourceID: self.source.id,
                    page: page,
                    pageSize: self.pagination.pageSize
                )
                guard !Task.isCancelled else { return }
                self.articles.append(contentsOf: result.articles)
                self.pagination.advance(fetchedCount: result.articles.count, total: result.totalResults)
                self.hasMorePages = self.pagination.hasMorePages
            } catch {
                // Pagination failure is silent — the user can scroll and retry by reaching the bottom again.
            }
        }
    }

    private func mapError(_ error: Error) -> String {
        (error as? NetworkError)?.userMessage ?? error.localizedDescription
    }
}
