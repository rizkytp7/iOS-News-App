import Foundation

/// Central access point for all API configuration values.
/// Values are read from the app's Info.plist, which is populated by Secrets.xcconfig
/// via build settings. The xcconfig key NEWS_API_KEY must be bridged to Info.plist
/// using the build setting $(NEWS_API_KEY).
enum APIConfiguration {

    // MARK: - API Key

    /// The NewsAPI key read from Info.plist.
    /// Crashes at launch with a descriptive message if the key is missing,
    /// so the developer notices immediately rather than getting silent 401 errors.
    static var apiKey: String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String,
            !value.isEmpty,
            value != "YOUR_API_KEY"
        else {
            fatalError(
                """
                ❌  NEWS_API_KEY is not configured.
                1. Copy Resources/Secrets.xcconfig.example → Secrets.xcconfig
                2. Set NEWS_API_KEY = <your key>
                3. In Build Settings add NEWS_API_KEY = $(NEWS_API_KEY)
                4. In Info.plist add <key>NEWS_API_KEY</key><string>$(NEWS_API_KEY)</string>
                """
            )
        }
        return value
    }

    // MARK: - Base URL

    static let baseURL = "https://newsapi.org/v2"

    // MARK: - Pagination defaults

    static let defaultPageSize = 20
}
