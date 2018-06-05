import Vapor
import FluentMySQL

/// Категория
final class Category: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: Int?
    /// Название
    var title: String
    
    
    // MARK: - Инициализация
    
    init(title: String) {
        self.title = title
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
                let category = Category(title: title)
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

extension Category: Migration { }


// MARK: - Content

extension Category: Content { }


// MARK: - Parameter

extension Category: Parameter { }
