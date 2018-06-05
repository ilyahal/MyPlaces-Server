import Vapor

/// Информация о месте
struct PlaceData: Content {
    
    /// Название
    var title: String
    /// Описание
    var description: String?
    /// Широта
    var latitude: Double
    /// Долгота
    var longitude: Double
    /// Публичный
    var isPublic: Bool
    /// Категории
    var categories: [String]?
    
}
