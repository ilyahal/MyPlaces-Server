import Vapor
import FluentSQLite

/// Список мест
final class List: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: UUID?
    /// Название
    var title: String
    /// Описание
    var description: String?
    /// Дата добавления
    var dateInsert: Date
    /// Дата изменения
    var dateUpdate: Date?
    /// Идентификатор пользователя
    var userID: User.ID
    
    
    // MARK: - Инициализация
    
    init(title: String, description: String?, dateInsert: Date, userID: User.ID) {
        self.title = title
        self.description = description
        self.dateInsert = dateInsert
        self.userID = userID
    }
    
}


// MARK: - Публичные свойства

extension List {
    
    /// Пользователь
    var user: Parent<List, User> {
        return parent(\.userID)
    }
    
}


// MARK: - SQLiteUUIDModel

extension List: SQLiteUUIDModel { }


// MARK: - Migration

extension List: Migration {
    
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
    
}


// MARK: - Content

extension List: Content { }


// MARK: - Parameter

extension List: Parameter { }
