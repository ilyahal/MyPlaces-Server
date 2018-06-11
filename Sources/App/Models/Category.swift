import Vapor
import FluentMySQL

/// Категория
final class Category: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: Int?
    /// Название
    var title: String
    /// Дата добавления
    var dateInsert: Date
    
    
    // MARK: - Инициализация
    
    init(title: String, dateInsert: Date) {
        self.title = title
        self.dateInsert = dateInsert
    }
    
}


// MARK: - Публичные свойства

extension Category {
    
    /// Места
    var places: Siblings<Category, Place, PlaceCategoryPivot> {
        return siblings()
    }
    
}


// MARK: - Публичные методы

extension Category {
    
    /// Добавить категорию для места
    static func addCategory(_ title: String, to place: Place, on request: Request) throws -> Future<Void> {
        let titleFilter: ModelFilter<Category> = try \.title == title
        return Category.query(on: request).filter(titleFilter).first().flatMap(to: Void.self) { category in
            if let existingCategory = category {
                return try PlaceCategoryPivot.createPivot(for: place, with: existingCategory, on: request)
            } else {
                let category = Category(title: title, dateInsert: Date())
                return category.save(on: request).flatMap(to: Void.self) { savedCategory in
                    return try PlaceCategoryPivot.createPivot(for: place, with: savedCategory, on: request)
                }
            }
        }
    }
    
}


// MARK: - MySQLModel

extension Category: MySQLModel { }


// MARK: - Migration

extension Category: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addIndex(to: \.title, isUnique: true)
        }
    }
    
}


// MARK: - Content

extension Category: Content { }


// MARK: - Parameter

extension Category: Parameter { }
