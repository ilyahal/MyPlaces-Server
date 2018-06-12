import Vapor
import CoreLocation

/// Работа с рекомендациями
struct RecommendationsController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "recommendations"
        let recommendationsRoutes = router.grouped("recommendations")
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = recommendationsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Получение рекомендаций
        tokenAuthGroup.post(RecommendationsData.self, use: getHandler)
    }
    
}


// MARK: - Приватные методы

private extension RecommendationsController {
    
    /// Получение рекомендаций
    func getHandler(_ request: Request, data: RecommendationsData) throws -> Future<[Place]> {
        let categoryId = data.category ?? -1
        
        return try Category.find(categoryId, on: request).flatMap(to: [Place].self) { category in
            let user = try request.requireAuthenticated(User.self)
            let target = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            let distanceInMeters = data.distance * 1000
            
            let recommendationsService = try request.make(RecommendationsService.self)
            return try recommendationsService.getRecommendations(for: user, target: target, distanceInMeters: distanceInMeters, category: category, includeOwned: data.includeOwned, on: request)
        }
    }
    
}
