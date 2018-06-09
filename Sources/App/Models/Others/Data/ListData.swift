import Vapor

/// Информация о списке
struct ListData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Название
    let title: String
    /// Описание
    let description: String?
    
}


// MARK: - Content

extension ListData: Content { }
