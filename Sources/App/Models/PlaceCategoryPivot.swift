import Vapor
import FluentMySQL

final class PlaceCategoryPivot: MySQLUUIDPivot {
    
    // MARK: - Типы данных
    
    typealias Left = Place
    typealias Right = Category
    
    
    // MARK: - Публичные свойства
    
    static let leftIDKey: LeftIDKey = \.placeID
    static let rightIDKey: RightIDKey = \.categoryID
    
    
    // MARK: - Публичные свойства
    
    /// Идентификатор
    var id: UUID?
    /// Идентификатор места
    var placeID: Place.ID
    /// Идентификатор категории
    var categoryID: Category.ID
    
    
    // MARK: - Инициализация
    
    init(_ placeID: Place.ID, _ categoryID: Category.ID) {
        self.placeID = placeID
        self.categoryID = categoryID
    }
    
}


// MARK: - Публичные методы

extension PlaceCategoryPivot {
    
    /// Создать связь для места и категории
    static func createPivot(for place: Place, with category: Category, on request: Request) throws -> Future<Void> {
        let pivot = try PlaceCategoryPivot(place.requireID(), category.requireID())
        return pivot.save(on: request).transform(to: ())
    }
    
    /// Удалить связь для места и категории
    static func deletePivot(for place: Place, with category: Category, on request: Request) throws -> Future<Void> {
        let placeFilter: ModelFilter<PlaceCategoryPivot> = try \.placeID == place.requireID()
        let categoryFilter: ModelFilter<PlaceCategoryPivot> = try \.categoryID == category.requireID()
        return PlaceCategoryPivot.query(on: request).filter(placeFilter).filter(categoryFilter).delete()
    }
    
}


// MARK: - Migration

extension PlaceCategoryPivot: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.placeID, to: \Place.id)
            try builder.addReference(from: \.categoryID, to: \Category.id)
        }
    }
    
}
