import Vapor

/// API
struct ApiController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "api"
        let apiRoutes = router.grouped("api")
        
        // Работа с пользователями
        let usersController = UsersController()
        try apiRoutes.register(collection: usersController)
        
        // Работа со списками
        let listsController = ListsController()
        try apiRoutes.register(collection: listsController)
        
        // Работа с местами
        let placesController = PlacesController()
        try apiRoutes.register(collection: placesController)
        
        // Работа с категориями
        let categoriesController = CategoriesController()
        try apiRoutes.register(collection: categoriesController)
        
        // Работа с рекомендациями
        let recommendationsController = RecommendationsController()
        try apiRoutes.register(collection: recommendationsController)
        
        // Работа с изображениями
        let imagesController = ImagesController()
        try apiRoutes.register(collection: imagesController)
    }
    
}
