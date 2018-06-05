import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // API
    let apiController = ApiController()
    try router.register(collection: apiController)
}
