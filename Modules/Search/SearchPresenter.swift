import Foundation
import Observation

// MARK: - Protocol

protocol SearchPresenterProtocol: AnyObject {
    var viewState: SearchViewState { get }
    var searchText: String { get set }
    var sources: [NewsSource] { get }
    var articles: [Article] { get }
    var isLoadingMore: Bool { get }
    var hasMorePages: Bool { get }
    var context: SearchContext { get }
    func viewDidAppear()
    func retry()
    func loadMoreIfNeeded(articleID: String)
    func didSelectSource(_ source: NewsSource)
    func didSelectArticle(_ article: Article)
}

// MARK: - Implementation

@Observable
@MainActor
final class SearchPresenter: @MainActor SearchPresenterProtocol {

    // MARK: - State

    private(set) var viewState: SearchViewState = .idle
    private(set) var sources: [NewsSource] = []
    private(set) var articles: [Article] = []
    private(set) var isLoadingMore: Bool = false
    private(set) var hasMorePages: Bool = false
    let context: SearchContext

    var searchText: String = "" {
        didSet { scheduleSearch() }
    }

    // MARK: - Private

    private var pagination = SearchPaginationState()
    private let interactor: any SearchInteractorProtocol
    private let router: any SearchRouterProtocol
    private var searchTask: Task<Void, Never>?

    init(
        context: SearchContext,
        interactor: any SearchInteractorProtocol,
        router: any SearchRouterProtocol
    ) {
        self.context = context
        self.interactor = interactor
        self.router = router
    }

    // MARK: - SearchPresenterProtocol

    func viewDidAppear() {}

    func retry() {
        scheduleSearch(immediate: true)
    }

    func loadMoreIfNeeded(articleID: String) {
        guard
            case .articles = context,
            hasMorePages,
            !isLoadingMore,
            articles.last?.id == articleID
        else { return }
        loadMoreArticles()
    }

    func didSelectSource(_ source: NewsSource) {
        router.navigateToArticles(for: source)
    }

    func didSelectArticle(_ article: Article) {
        router.navigateToArticleDetail(article)
    }

    // MARK: - Private

    private func scheduleSearch(immediate: Bool = false) {
        searchTask?.cancel()
        let query = searchText
        let delay: UInt64 = immediate ? 0 : 350_000_000

        searchTask = Task {
            if delay > 0 { try? await Task.sleep(nanoseconds: delay) }
            guard !Task.isCancelled else { return }
            let trimmed = query.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                self.reset()
                return
            }
            await self.performSearch(query: trimmed, page: 1, appending: false)
        }
    }

    private func reset() {
        sources = []
        articles = []
        pagination.reset()
        hasMorePages = false
        viewState = .idle
    }

    private func performSearch(query: String, page: Int, appending: Bool) async {
        if !appending {
            pagination.reset()
            viewState = .loading
        }

        do {
            switch context {
            case .sources(let category):
                let results = try await interactor.searchSources(category: category, query: query)
                guard !Task.isCancelled else { return }
                sources = results
                viewState = results.isEmpty ? .empty : .loaded

            case .articles(let source):
                let result = try await interactor.searchArticles(
                    source: source,
                    query: query,
                    page: page,
                    pageSize: pagination.pageSize
                )
                guard !Task.isCancelled else {
                    isLoadingMore = false
                    return
                }
                if appending {
                    articles.append(contentsOf: result.articles)
                } else {
                    articles = result.articles
                }
                pagination.advance(fetchedCount: result.articles.count, total: result.totalResults)
                hasMorePages = pagination.hasMorePages
                viewState = articles.isEmpty ? .empty : .loaded
            }
        } catch {
            guard !Task.isCancelled else {
                isLoadingMore = false
                return
            }
            viewState = .error(mapError(error))
        }
        isLoadingMore = false
    }

    private func loadMoreArticles() {
        guard case .articles = context, !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        let page = pagination.currentPage
        let query = searchText.trimmingCharacters(in: .whitespaces)

        searchTask = Task {
            await self.performSearch(query: query, page: page, appending: true)
        }
    }

    private func mapError(_ error: Error) -> String {
        (error as? NetworkError)?.userMessage ?? error.localizedDescription
    }
}
