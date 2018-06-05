import Vapor
import FluentSQLite

/// Место
final class Place: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: UUID?
    /// Название
    var title: String
    /// Описание
    var description: String?
    /// Широта
    var latitude: Double
    /// Долгота
    var longitude: Double
    /// Публичный
    var isPublic: Bool
    /// Дата добавления
    var dateInsert: Date
    /// Дата изменения
    var dateUpdate: Date?
    /// Идентификатор списка
    var listID: List.ID
    /// Идентификатор пользователя
    var userID: User.ID
    
    
    // MARK: - Инициализация
    
    init(title: String, description: String?, latitude: Double, longitude: Double, isPublic: Bool, dateInsert: Date, listID: List.ID, userID: User.ID) {
        self.title = title
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.isPublic = isPublic
        self.dateInsert = dateInsert
        self.listID = listID
        self.userID = userID
    }
    
}


// MARK: - Публичные свойства

extension Place {
    
    /// Пользователь
    var user: Parent<Place, User> {
        return parent(\.userID)
    }
    
    /// Список
    var list: Parent<Place, List> {
        return parent(\.listID)
    }
    
}


// MARK: - SQLiteUUIDModel

extension Place: SQLiteUUIDModel { }


// MARK: - Migration

extension Place: Migration {
    
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
            try builder.addReference(from: \.listID, to: \List.id)
        }
    }
    
}


// MARK: - Content

extension Place: Content { }


// MARK: - Parameter

extension Place: Parameter { }
