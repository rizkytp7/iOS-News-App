import SwiftUI

/// A reusable search bar component compatible with iOS 17+.
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
                .accessibilityIdentifier("search_field")
                .accessibilityLabel("Search field")
                .accessibilityHint("Type to search")

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
                .accessibilityIdentifier("clear_search_button")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
