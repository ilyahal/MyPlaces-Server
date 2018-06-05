import Vapor
import Crypto
import Authentication
import FluentMySQL

/// Токен
final class Token: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: UUID?
    /// Значение
    var token: String
    /// Идентификатор пользователя
    var userID: User.ID
    
    
    // MARK: - Инициализация
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
}


// MARK: - Публичные свойства

extension Token {
    
    /// Пользователь
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
    
}


// MARK: - Публичные методы

extension Token {
    
    /// Создать токен для пользователя
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
    
}


// MARK: - MySQLUUIDModel

extension Token: MySQLUUIDModel { }


// MARK: - Migration

extension Token: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
    
}


// MARK: - Content

extension Token: Content { }


// MARK: - Token

extension Token: Authentication.Token {
    
    typealias UserType = User
    
    static let userIDKey: UserIDKey = \.userID
    
}


// MARK: - BearerAuthenticatable

extension Token: BearerAuthenticatable {
    
    static let tokenKey: TokenKey = \.token
    
}
