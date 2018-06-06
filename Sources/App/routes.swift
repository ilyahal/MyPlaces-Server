import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Сайт
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
    // API
    let apiController = ApiController()
    try router.register(collection: apiController)
}
