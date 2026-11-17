import Foundation

/// Composition root. Holds shared infrastructure passed to every VIPER Builder.
/// Created once at app launch and stored in SwiftUI @State.
final class AppEnvironment: @unchecked Sendable {

    let apiClient: any APIClient
    let repository: any NewsRepositoryProtocol

    init(
        apiClient: (any APIClient)? = nil,
        repository: (any NewsRepositoryProtocol)? = nil
    ) {
        let client = apiClient ?? URLSessionAPIClient()
        self.apiClient = client
        self.repository = repository ?? NewsRepositoryImpl(apiClient: client)
    }
}
