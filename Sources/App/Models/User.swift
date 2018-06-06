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
    /// URL фотографии
    var photoUrl: String?
    
    
    // MARK: - Инициализация
    
    init(name: String, username: String, password: String, email: String?, photoUrl: String?) {
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
    
    /// Проверка на существование
    static func checkExisting(withUsername username: String, on request: Request) throws -> Future<Bool> {
        let usernameFilter: ModelFilter<User> = try \.username == username
        return User.query(on: request).filter(usernameFilter).first().map(to: Bool.self) { $0 != nil }
    }
    
    /// Создать пароль
    static func createPassword(with source: String, on request: Request) throws -> String {
        let hasher = try request.make(BCryptDigest.self)
        return try hasher.hash(source)
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


// MARK: - PasswordAuthenticatable

extension User: PasswordAuthenticatable { }


// MARK: - SessionAuthenticatable

extension User: SessionAuthenticatable { }
