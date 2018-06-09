import Vapor

/// Информация о категории
struct CategoryData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Название
    let title: String
    
}


// MARK: - Content

extension CategoryData: Content { }
