import SwiftUI

/// The fixed set of categories supported by NewsAPI /v2/top-headlines/sources.
enum NewsCategory: String, CaseIterable, Identifiable, Sendable {
    case general
    case business
    case entertainment
    case health
    case science
    case sports
    case technology

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .general:       return "newspaper"
        case .business:      return "briefcase"
        case .entertainment: return "film"
        case .health:        return "heart.text.square"
        case .science:       return "flask"
        case .sports:        return "sportscourt"
        case .technology:    return "cpu"
        }
    }

    var accentColor: Color {
        switch self {
        case .general:       return .blue
        case .business:      return .green
        case .entertainment: return .purple
        case .health:        return .red
        case .science:       return .teal
        case .sports:        return .orange
        case .technology:    return .indigo
        }
    }

    var accessibilityIdentifier: String {
        "category_\(rawValue)"
    }
}
