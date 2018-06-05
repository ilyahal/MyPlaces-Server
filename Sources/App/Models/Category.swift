import Vapor
import FluentSQLite

/// Категория
final class Category: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: Int?
    /// Название
    var title: String
    
    
    // MARK: - Инициализация
    
    init(title: String) {
        self.title = title
    }
    
}


// MARK: - SQLiteUUIDModel

extension Category: SQLiteModel { }


// MARK: - Migration

extension Category: Migration { }


// MARK: - Content

extension Category: Content { }


// MARK: - Parameter

extension Category: Parameter { }
