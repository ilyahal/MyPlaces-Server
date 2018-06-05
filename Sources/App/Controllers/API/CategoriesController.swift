import Vapor

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
    
    /// Создание категории
    func createHandler(_ request: Request, category: Category) throws -> Future<Category> {
        return category.save(on: request)
    }
    
}
