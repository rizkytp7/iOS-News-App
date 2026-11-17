import Foundation
import Observation

// MARK: - Protocol

protocol SourcesPresenterProtocol: AnyObject {
    var viewState: SourcesViewState { get }
    var displayedSources: [NewsSource] { get }
    var isLoadingMore: Bool { get }
    var hasMorePages: Bool { get }
    var searchText: String { get set }
    func viewDidAppear()
    func retry()
    func loadMoreIfNeeded(currentItem: NewsSource)
    func didSelectSource(_ source: NewsSource)
    func didTapSearch()
}

// MARK: - Implementation

@Observable
@MainActor
final class SourcesPresenter: @MainActor SourcesPresenterProtocol {

    // MARK: - State

    private(set) var viewState: SourcesViewState = .idle
    private(set) var displayedSources: [NewsSource] = []
    private(set) var isLoadingMore: Bool = false
    private(set) var hasMorePages: Bool = false

    var searchText: String = "" {
        didSet { scheduleFilter() }
    }

    // MARK: - Private state

    private var pagination = SourcesPaginationState()
    private let category: NewsCategory
    private let interactor: any SourcesInteractorProtocol
    private let router: any SourcesRouterProtocol
    private var debounceTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    init(
        category: NewsCategory,
        interactor: any SourcesInteractorProtocol,
        router: any SourcesRouterProtocol
    ) {
        self.category = category
        self.interactor = interactor
        self.router = router
    }

    // MARK: - SourcesPresenterProtocol

    func viewDidAppear() {
        guard viewState == .idle else { return }
        load()
    }

    func retry() {
        pagination.reset()
        viewState = .idle
        load()
    }

    func loadMoreIfNeeded(currentItem: NewsSource) {
        guard
            hasMorePages,
            !isLoadingMore,
            let lastID = displayedSources.last?.id,
            currentItem.id == lastID
        else { return }
        loadMore()
    }

    func didSelectSource(_ source: NewsSource) {
        router.navigateToArticles(for: source)
    }

    func didTapSearch() {
        router.navigateToSearch(category: category)
    }

    // MARK: - Private

    private func load() {
        loadTask?.cancel()
        loadTask = Task {
            self.viewState = .loading
            do {
                let sources = try await self.interactor.fetchSources(category: self.category)
                self.pagination.reset()
                self.pagination.allSources = sources
                let pageSize = self.pagination.pageSize
                let firstSlice = Array(sources.prefix(pageSize))
                self.pagination.displayedSources = firstSlice
                self.pagination.currentPage = 1
                self.pagination.hasMorePages = sources.count > pageSize
                self.displayedSources = firstSlice
                self.hasMorePages = self.pagination.hasMorePages
                self.viewState = sources.isEmpty ? .empty : .loaded
            } catch {
                guard !Task.isCancelled else { return }
                self.viewState = .error(self.mapError(error))
            }
        }
    }

    private func loadMore() {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        pagination.loadNextPage()
        displayedSources = pagination.displayedSources
        hasMorePages = pagination.hasMorePages
        isLoadingMore = false
    }

    private func scheduleFilter() {
        debounceTask?.cancel()
        let query = searchText

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            self.applyFilter(query: query)
        }
    }

    private func applyFilter(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            let pageSize = pagination.pageSize
            displayedSources = Array(pagination.allSources.prefix(pageSize))
            hasMorePages = pagination.allSources.count > pageSize
            pagination.currentPage = 1
            pagination.displayedSources = displayedSources
            pagination.hasMorePages = hasMorePages
            viewState = displayedSources.isEmpty ? .empty : .loaded
        } else {
            let filtered = pagination.allSources.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed) ||
                $0.description.localizedCaseInsensitiveContains(trimmed)
            }
            displayedSources = filtered
            hasMorePages = false
            viewState = filtered.isEmpty ? .empty : .loaded
        }
    }

    private func mapError(_ error: Error) -> String {
        (error as? NetworkError)?.userMessage ?? error.localizedDescription
    }
}
