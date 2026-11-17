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

- This project uses VIPER Architecture.
┌──────────────┐
│     View     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Presenter  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Interactor  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Repository  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  API Client  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   URLSession │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   NewsAPI    │
└──────────────┘

📂 Project Structure
NewsReader/
│
├── App/
│   ├── NewsReaderApp.swift
│   ├── AppEnvironment.swift
│   └── AppRouter.swift
│
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── APIEndpoint.swift
│   │   ├── NetworkError.swift
│   │   └── URLSessionAPIClient.swift
│   │
│   ├── Configuration/
│   │   └── APIConfiguration.swift
│   │
│   ├── Components/
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   ├── EmptyStateView.swift
│   │   ├── AsyncImageView.swift
│   │   └── SearchBar.swift
│   │
│   └── Utilities/
│
├── Data/
│   ├── API/
│   │   ├── NewsAPIClient.swift
│   │   └── NewsAPIEndpoint.swift
│   │
│   ├── DTO/
│   │   ├── NewsSourceDTO.swift
│   │   ├── ArticleDTO.swift
│   │   └── APIResponseDTO.swift
│   │
│   └── Repository/
│       ├── NewsRepository.swift
│       └── NewsRepositoryImpl.swift
│
├── Domain/
│   ├── Models/
│   │   ├── NewsCategory.swift
│   │   ├── NewsSource.swift
│   │   └── Article.swift
│   │
│   └── Repository/
│       └── NewsRepositoryProtocol.swift
│
├── Modules/
│   │
│   ├── Categories/
│   │   ├── CategoriesView.swift
│   │   ├── CategoriesPresenter.swift
│   │   ├── CategoriesInteractor.swift
│   │   ├── CategoriesRouter.swift
│   │   ├── CategoriesEntity.swift
│   │   └── CategoriesBuilder.swift
│   │
│   ├── Sources/
│   │   ├── SourcesView.swift
│   │   ├── SourcesPresenter.swift
│   │   ├── SourcesInteractor.swift
│   │   ├── SourcesRouter.swift
│   │   ├── SourcesEntity.swift
│   │   └── SourcesBuilder.swift
│   │
│   ├── Articles/
│   │   ├── ArticlesView.swift
│   │   ├── ArticlesPresenter.swift
│   │   ├── ArticlesInteractor.swift
│   │   ├── ArticlesRouter.swift
│   │   ├── ArticlesEntity.swift
│   │   └── ArticlesBuilder.swift
│   │
│   ├── ArticleDetail/
│   │   ├── ArticleDetailView.swift
│   │   ├── ArticleDetailPresenter.swift
│   │   ├── ArticleDetailInteractor.swift
│   │   ├── ArticleDetailRouter.swift
│   │   ├── ArticleDetailEntity.swift
│   │   └── ArticleDetailBuilder.swift
│   │
│   └── Search/
│       ├── SearchView.swift
│       ├── SearchPresenter.swift
│       ├── SearchInteractor.swift
│       ├── SearchRouter.swift
│       ├── SearchEntity.swift
│       └── SearchBuilder.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── Localizations/
│
└── Tests/
    ├── NetworkTests/
    ├── RepositoryTests/
    ├── CategoriesTests/
    ├── SourcesTests/
    ├── ArticlesTests/
    └── SearchTests/
