import Vapor

/// Информация о фильтрах рекомендаций при работе с сайтом
struct RecommendationsWebsiteData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Широта
    let latitude: Double
    /// Долгота
    let longitude: Double
    /// Категории
    let category: String
    /// Дистанция
    let distance: Double
    /// Включая собственные места
    let includeOwned: String?
    
}


// MARK: - Content

extension RecommendationsWebsiteData: Content { }
