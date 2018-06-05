import Vapor
import FluentMySQL

/// Изображение
final class Image: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: Int?
    /// Название
    var name: String
    /// Дата добавления
    var dateInsert: Date
    /// Идентификатор пользователя
    var userID: User.ID
    
    
    // MARK: - Инициализация
    
    init(name: String, dateInsert: Date, userID: User.ID) {
        self.name = name
        self.dateInsert = dateInsert
        self.userID = userID
    }
    
}


// MARK: - Публичные свойства

extension Image {
    
    /// Пользователь
    var user: Parent<Image, User> {
        return parent(\.userID)
    }
    
}


// MARK: - MySQLModel

extension Image: MySQLModel { }


// MARK: - Migration

extension Image: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
    
}


// MARK: - Content

extension Image: Content { }


// MARK: - Parameter

extension Image: Parameter { }
