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
    }
    
}
