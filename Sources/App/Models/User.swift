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
    var email: String
    /// URL фотографии
    var photoUrl: String?
    
    
    // MARK: - Инициализация
    
    init(name: String, username: String, password: String, email: String, photoUrl: String?) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
        self.photoUrl = photoUrl
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
    
    /// Изображения
    var images: Children<User, Image> {
        return children(\.userID)
    }
    
}


// MARK: - Публичные методы

extension User {
    
    /// Преобразовать в публичную версию
    func convertToPublic() -> User.Public {
        return User.Public(id: self.id, name: self.name, username: self.username, email: self.email, photoUrl: self.photoUrl)
    }
    
}


// MARK: - MySQLUUIDModel

extension User: MySQLUUIDModel { }


// MARK: - Migration

extension User: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addIndex(to: \.username, isUnique: true)
        }
    }
    
}


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


// MARK: - PasswordAuthenticatable

extension User: PasswordAuthenticatable { }


// MARK: - SessionAuthenticatable

extension User: SessionAuthenticatable { }
