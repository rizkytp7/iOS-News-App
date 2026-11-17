import Foundation
import Observation

// MARK: - Protocol

protocol ArticleDetailPresenterProtocol: AnyObject {
    var viewState: ArticleDetailViewState { get }
    var articleURL: URL? { get }
    var articleTitle: String { get }
    func viewDidAppear()
    func webViewDidStartLoad()
    func webViewDidFinishLoad()
    func webViewDidFailLoad(error: Error)
    func retry()
}

// MARK: - Implementation

@Observable
@MainActor
final class ArticleDetailPresenter: @MainActor ArticleDetailPresenterProtocol {

    // MARK: - State

    private(set) var viewState: ArticleDetailViewState = .idle
    private(set) var articleURL: URL?
    let articleTitle: String

    // MARK: - Private

    private let article: Article
    private let interactor: any ArticleDetailInteractorProtocol

    init(article: Article, interactor: any ArticleDetailInteractorProtocol) {
        self.article = article
        self.articleTitle = article.title
        self.interactor = interactor
    }

    // MARK: - ArticleDetailPresenterProtocol

    func viewDidAppear() {
        guard let url = interactor.resolveURL(from: article.url) else {
            viewState = .error("This article has an invalid URL and cannot be displayed.")
            return
        }
        articleURL = url
        viewState = .loading
    }

    func webViewDidStartLoad() {
        viewState = .loading
    }

    func webViewDidFinishLoad() {
        viewState = .loaded
    }

    func webViewDidFailLoad(error: Error) {
        viewState = .error("Failed to load the article. Please check your connection and try again.")
    }

    func retry() {
        guard let _ = articleURL else {
            viewState = .error("This article has an invalid URL and cannot be displayed.")
            return
        }
        viewState = .loading
    }
}
