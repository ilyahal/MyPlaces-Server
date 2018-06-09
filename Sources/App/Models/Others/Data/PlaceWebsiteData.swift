import Vapor

/// Информация о месте при работе с сайтом
struct PlaceWebsiteData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Название
    let title: String
    /// Описание
    let description: String?
    /// Широта
    let latitude: Double
    /// Долгота
    let longitude: Double
    /// Публичный
    let isPublic: String?
    /// Категории
    let categories: [String]?
    
}


// MARK: - Content

extension PlaceWebsiteData: Content { }
