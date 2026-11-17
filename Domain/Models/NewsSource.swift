import Foundation

struct NewsSource: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: NewsCategory
    let language: String
    let country: String
}
