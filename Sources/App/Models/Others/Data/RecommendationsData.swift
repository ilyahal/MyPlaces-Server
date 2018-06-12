import Vapor

/// Информация о фильтрах рекомендаций
struct RecommendationsData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Широта
    let latitude: Double
    /// Долгота
    let longitude: Double
    /// Категории
    let category: Category.ID?
    /// Дистанция
    let distance: Double
    /// Включая собственные места
    let includeOwned: Bool
    
}


// MARK: - Content

extension RecommendationsData: Content { }
