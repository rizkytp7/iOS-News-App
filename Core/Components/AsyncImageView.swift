import SwiftUI

/// A wrapper around AsyncImage that shows a branded placeholder while loading
/// and a fallback when the URL is nil or the image fails to load.
struct AsyncImageView: View {
    let urlString: String?
    var aspectRatio: CGFloat = 16 / 9
    var cornerRadius: CGFloat = 0

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        fallbackView
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(aspectRatio, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .clipped()
    }

    // MARK: - Private views

    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            ProgressView()
                .progressViewStyle(.circular)
        }
    }

    private var fallbackView: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
        }
    }
}
