import Vapor
import Fluent

/// Работа с категориями
struct CategoriesController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "categories"
        let categoriesRoutes = router.grouped("categories")
        
        // Получение всех категорий
        categoriesRoutes.get(use: getAllHandler)
        // Получение категории
        categoriesRoutes.get(Category.parameter, use: getHandler)
        // Получение мест в категории
        categoriesRoutes.get(Category.parameter, "places", use: getPlacesHandler)
        // Создание категории
        categoriesRoutes.post(Category.self, use: createHandler)
    }

}


// MARK: - Приватные методы

private extension CategoriesController {
    
    /// Получение всех категорий
    func getAllHandler(_ request: Request) throws -> Future<[Category]> {
        return Category.query(on: request).all()
    }
    
    /// Получение категории
    func getHandler(_ request: Request) throws -> Future<Category> {
        return try request.parameters.next(Category.self)
    }
    
    /// Получение мест в категории
    func getPlacesHandler(_ request: Request) throws -> Future<[Place]> {
        return try request.parameters.next(Category.self).flatMap(to: [Place].self) { category in
            let publicFilter: ModelFilter<Place> = try \.isPublic == true
            return try category.places.query(on: request).filter(publicFilter).all()
        }
    }
    
    /// Создание категории
    func createHandler(_ request: Request, category: Category) throws -> Future<Category> {
        return category.save(on: request)
    }
    
}
