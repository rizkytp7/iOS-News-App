import Foundation

// MARK: - Protocol

protocol SourcesInteractorProtocol: AnyObject, Sendable {
    func fetchSources(category: NewsCategory) async throws -> [NewsSource]
}

// MARK: - Implementation

final class SourcesInteractor: SourcesInteractorProtocol, @unchecked Sendable {

    private let repository: any NewsRepositoryProtocol

    init(repository: any NewsRepositoryProtocol) {
        self.repository = repository
    }

    func fetchSources(category: NewsCategory) async throws -> [NewsSource] {
        try await repository.fetchSources(
            category: category.rawValue,
            language: nil,
            country: nil
        )
    }
}
