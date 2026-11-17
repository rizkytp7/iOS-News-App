import SwiftUI

enum ArticleDetailBuilder {

    @MainActor static func build(article: Article) -> ArticleDetailView {
        let router = ArticleDetailRouter()
        let interactor = ArticleDetailInteractor()
        let presenter = ArticleDetailPresenter(article: article, interactor: interactor)
        return ArticleDetailView(presenter: presenter)
    }
}
