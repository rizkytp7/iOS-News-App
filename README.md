# 📰 News Reader iOS
A modern native iOS News Reader application built with **SwiftUI**, **VIPER Architecture**, and **NewsAPI**.
The application allows users to explore news categories, discover news sources, browse articles, search for news, and read the original article through an integrated WebView.

---
## ✨ Features
- 🗂️ Browse news categories
- 📰 Browse news sources
- 🔎 Search news sources
- 🔍 Search news articles
- 📄 Article detail
- 🌐 Open original article using `WKWebView`
- ♾️ Endless scrolling for articles
- 📑 Pagination using NewsAPI `page` and `pageSize`
- 🔄 Pull-to-refresh
- ⚠️ Error handling
- 🔁 Retry failed requests
- 🕳️ Empty states
- 🖼️ Image loading with fallback placeholder
- 🌙 Light & Dark Mode
- ♿ Accessibility support
- 🧪 Unit-testable architecture
- 📱 Physical iPhone support
---

# 📱 Application Flow
                    ┌─────────────────┐
                    │   Categories    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │     Sources     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Articles     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Article Detail  │
                    │    WKWebView    │
                    └─────────────────┘
