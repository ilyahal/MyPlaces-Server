import Vapor

/// Информация о месте
struct PlaceData: Content {
    
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
