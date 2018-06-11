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
        // Создание категории
        categoriesRoutes.post(CategoryData.self, use: createHandler)
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = categoriesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Получение мест в категории
        tokenAuthGroup.get(Category.parameter, "places", use: getPlacesHandler)
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
    func createHandler(_ request: Request, data: CategoryData) throws -> Future<Category> {
        let category = Category(title: data.title, dateInsert: Date())
        return category.save(on: request)
    }
    
    /// Получение мест в категории
    func getPlacesHandler(_ request: Request) throws -> Future<[Place]> {
        return try request.parameters.next(Category.self).flatMap(to: [Place].self) { category in
            let user = try request.requireAuthenticated(User.self)
            
            let publicFilter: ModelFilter<Place> = try \.isPublic == true
            let selfPlaceFilter: ModelFilter<Place> = try \.userID == user.id
            
            return try category.places.query(on: request).group(.or) { or in
                or.filter(publicFilter)
                or.filter(selfPlaceFilter)
            }.all()
        }
    }
    
}
