import Vapor

/// Информация о списке
struct ListData: Content {
    
    /// Название
    var title: String
    /// Описание
    var description: String?
    
}
