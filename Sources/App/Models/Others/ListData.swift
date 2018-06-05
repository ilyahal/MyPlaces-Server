import Vapor

/// Информация о списке
struct ListData: Content {
    
    /// Название
    let title: String
    /// Описание
    let description: String?
    
}
