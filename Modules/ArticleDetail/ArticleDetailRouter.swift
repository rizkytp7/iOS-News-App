import SwiftUI

// MARK: - Protocol

protocol ArticleDetailRouterProtocol: AnyObject {}

// MARK: - Implementation

/// ArticleDetail is a leaf screen — navigation only goes back via the system nav bar.
final class ArticleDetailRouter: ArticleDetailRouterProtocol {}
