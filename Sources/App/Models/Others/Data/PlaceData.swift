import Vapor

/// Информация о месте
struct PlaceData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Название
    let title: String
    /// Описание
    let description: String?
    /// Широта
    let latitude: Double
    /// Долгота
    let longitude: Double
    /// Название фотографии
    let photoName: String?
    /// Публичный
    let isPublic: Bool
    /// Категории
    let categories: [String]?
    
}


// MARK: - Content

extension PlaceData: Content { }
