import Vapor
import Authentication
import FluentMySQL

/// Пользователь
final class User: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: UUID?
    /// Имя
    var name: String
    /// Никнейм
    var username: String
    /// Пароль
    var password: String
    /// Адрес электронной почты
    var email: String?
    
    
    // MARK: - Инициализация
    
    init(name: String, username: String, password: String, email: String?) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
    }
    
}


// MARK: - Публичные свойства

extension User {
    
    /// Списки
    var lists: Children<User, List> {
        return children(\.userID)
    }
    
    /// Места
    var places: Children<User, Place> {
        return children(\.userID)
    }
    
}


// MARK: - MySQLUUIDModel

extension User: MySQLUUIDModel { }


// MARK: - Migration

extension User: Migration { }


// MARK: - Content

extension User: Content { }


// MARK: - Parameter

extension User: Parameter { }


// MARK: - BasicAuthenticatable

extension User: BasicAuthenticatable {
    
    static let usernameKey: UsernameKey = \.username
    static let passwordKey: PasswordKey = \.password
    
}


// MARK: - TokenAuthenticatable

extension User: TokenAuthenticatable {
    
    typealias TokenType = Token
    
}
