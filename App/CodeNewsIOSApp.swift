import SwiftUI

@main
struct CodeNewsIOSApp: App {

    @State private var navigationPath = NavigationPathStore()

    // AppEnvironment is created once and passed down through builders,
    // not through SwiftUI's environment (it doesn't need to be @Observable).
    private let appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath.path) {
                CategoriesBuilder.build(navigationPath: navigationPath)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
        }
    }

    // MARK: - Destination resolver

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .sources(let category):
            SourcesBuilder.build(
                category: category,
                repository: appEnvironment.repository,
                navigationPath: navigationPath
            )

        case .articles(let source):
            ArticlesBuilder.build(
                source: source,
                repository: appEnvironment.repository,
                navigationPath: navigationPath
            )

        case .articleDetail(let article):
            ArticleDetailBuilder.build(article: article)

        case .search(let context):
            SearchBuilder.build(
                context: context,
                repository: appEnvironment.repository,
                navigationPath: navigationPath
            )
        }
    }
}
