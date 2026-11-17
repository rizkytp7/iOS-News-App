import Foundation

struct Article: Identifiable, Equatable, Sendable {
    let id: String       // article URL used as stable ID
    let title: String
    let description: String?
    let url: String
    let imageURL: String?
    let author: String?
    let publishedAt: Date?
    let sourceName: String
}
