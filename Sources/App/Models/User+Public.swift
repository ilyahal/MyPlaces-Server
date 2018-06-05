import Vapor
import FluentSQLite

extension User {
    
    /// Публичная информация о пользователе
    final class Public: Codable {
        
        // MARK: - Публичные свойства
        
        /// Идентификатор
        var id: UUID?
        /// Имя
        var name: String
        /// Никнейм
        var username: String
        /// Адрес электронной почты
        var email: String?
        
        
        // MARK: - Инициализация
        
        init(name: String, username: String, email: String?) {
            self.name = name
            self.username = username
            self.email = email
        }
    }
    
}


// MARK: - SQLiteUUIDModel

extension User.Public: SQLiteUUIDModel {
    
    static let entity = User.entity
    
}


// MARK: - Content

extension User.Public: Content { }


// MARK: - Parameter

extension User.Public: Parameter { }
