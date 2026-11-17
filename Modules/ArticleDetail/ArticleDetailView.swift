import SwiftUI
import WebKit

struct ArticleDetailView: View {

    @State var presenter: ArticleDetailPresenter

    var body: some View {
        Group {
            switch presenter.viewState {
            case .idle:
                Color.clear
            case .loading:
                ZStack {
                    webViewIfAvailable
                    LoadingView(message: "Loading article…")
                }
            case .loaded:
                webViewIfAvailable
            case .error(let message):
                ErrorView(message: message) { presenter.retry() }
            }
        }
        .navigationTitle(presenter.articleTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.viewDidAppear() }
        .accessibilityIdentifier("article_detail_screen")
    }

    @ViewBuilder
    private var webViewIfAvailable: some View {
        if let url = presenter.articleURL {
            WebViewRepresentable(
                url: url,
                onStartLoad: { presenter.webViewDidStartLoad() },
                onFinishLoad: { presenter.webViewDidFinishLoad() },
                onFailLoad:  { presenter.webViewDidFailLoad(error: $0) }
            )
            .accessibilityIdentifier("article_webview")
        }
    }
}

// MARK: - WKWebView wrapper

struct WebViewRepresentable: UIViewRepresentable {

    let url: URL
    var onStartLoad: @MainActor () -> Void
    var onFinishLoad: @MainActor () -> Void
    var onFailLoad: @MainActor (Error) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onStartLoad: onStartLoad,
            onFinishLoad: onFinishLoad,
            onFailLoad: onFailLoad
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        if webView.url != url {
            webView.load(request)
        }
    }

    // MARK: - Coordinator (WKNavigationDelegate)

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {

        var onStartLoad: @MainActor () -> Void
        var onFinishLoad: @MainActor () -> Void
        var onFailLoad: @MainActor (Error) -> Void

        init(
            onStartLoad: @escaping @MainActor () -> Void,
            onFinishLoad: @escaping @MainActor () -> Void,
            onFailLoad: @escaping @MainActor (Error) -> Void
        ) {
            self.onStartLoad = onStartLoad
            self.onFinishLoad = onFinishLoad
            self.onFailLoad = onFailLoad
        }

        nonisolated func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in self.onStartLoad() }
        }

        nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in self.onFinishLoad() }
        }

        nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in self.onFailLoad(error) }
        }

        nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in self.onFailLoad(error) }
        }
    }
}
