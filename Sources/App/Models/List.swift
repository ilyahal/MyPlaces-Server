import Vapor
import FluentMySQL

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
    
    /// Места
    var places: Children<List, Place> {
        return children(\.listID)
    }
    
}


// MARK: - Публичные методы

extension List {
    
    /// Удалить список
    static func deleteList(_ list: List, on request: Request) throws -> Future<Void> {
        return try list.places.query(on: request).all().flatMap(to: Void.self) { places in
            var deletes: [Future<Void>] = []
            for place in places {
                let deletePlace = try Place.deletePlace(place, on: request)
                deletes.append(deletePlace)
            }
            
            return deletes.flatten(on: request).flatMap(to: Void.self) {
                return list.delete(on: request).transform(to: ())
            }
        }
    }
    
}


// MARK: - MySQLUUIDModel

extension List: MySQLUUIDModel { }


// MARK: - Migration

extension List: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
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
