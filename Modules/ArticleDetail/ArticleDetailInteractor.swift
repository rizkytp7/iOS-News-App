import Foundation

// MARK: - Protocol

protocol ArticleDetailInteractorProtocol: AnyObject {
    func resolveURL(from urlString: String) -> URL?
}

// MARK: - Implementation

final class ArticleDetailInteractor: ArticleDetailInteractorProtocol {

    /// Returns a valid URL or nil — never throws or crashes on bad input.
    func resolveURL(from urlString: String) -> URL? {
        guard !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
