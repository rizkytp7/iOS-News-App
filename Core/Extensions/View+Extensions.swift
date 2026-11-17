import SwiftUI

extension View {

    /// Applies a card-style background with rounded corners and a subtle shadow.
    func cardStyle() -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}
