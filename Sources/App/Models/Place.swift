import Vapor
import FluentMySQL

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
    
    /// Категории
    var categories: Siblings<Place, Category, PlaceCategoryPivot> {
        return siblings()
    }
    
}


// MARK: - Публичные методы

extension Place {
    
    /// Удалить место
    static func deletePlace(_ place: Place, on request: Request) throws -> Future<Void> {
        return try place.categories.query(on: request).all().flatMap(to: Void.self) { categories in
            var deletes: [Future<Void>] = []
            for category in categories {
                let deletePivot = try PlaceCategoryPivot.deletePivot(for: place, with: category, on: request)
                deletes.append(deletePivot)
            }
            
            return deletes.flatten(on: request).flatMap(to: Void.self) {
                return place.delete(on: request).transform(to: ())
            }
        }
    }
    
}


// MARK: - MySQLUUIDModel

extension Place: MySQLUUIDModel { }


// MARK: - Migration

extension Place: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
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
