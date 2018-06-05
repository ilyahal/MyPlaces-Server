import Vapor

/// Работа с местами
struct PlacesController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "places"
        let placesRoutes = router.grouped("places")
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = placesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Получение всех мест в списке
        tokenAuthGroup.get("list", List.parameter, use: getListHandler)
        // Получение места
        tokenAuthGroup.get(Place.parameter, use: getHandler)
        // Создание места
        tokenAuthGroup.post(PlaceData.self, at: "list", List.parameter, use: createHandler)
        // Изменение места
        tokenAuthGroup.put(PlaceData.self, at: Place.parameter, use: updateHandler)
        // Удаление места
        tokenAuthGroup.delete(Place.parameter, use: deleteHandler)
    }
    
}


// MARK: - Приватные методы

private extension PlacesController {
    
    /// Получение всех мест в списке
    func getListHandler(_ request: Request) throws -> Future<[Place]> {
        return try request.parameters.next(List.self).flatMap(to: [Place].self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            return try list.places.query(on: request).all() // TODO: Сортировка
        }
    }
    
    /// Получение места
    func getHandler(_ request: Request) throws -> Future<Place> {
        return try request.parameters.next(Place.self).map(to: Place.self) { place in
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            return place
        }
    }
    
    /// Создание места
    func createHandler(_ request: Request, data: PlaceData) throws -> Future<Place> {
        return try request.parameters.next(List.self).flatMap(to: Place.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let place = try Place(title: data.title, description: data.description, latitude: data.latitude, longitude: data.longitude, isPublic: data.isPublic, dateInsert: Date(), listID: list.requireID(), userID: user.requireID())
            return place.save(on: request)
        }
    }
    
    /// Изменение места
    func updateHandler(_ request: Request, data: PlaceData) throws -> Future<Place> {
        return try request.parameters.next(Place.self).flatMap(to: Place.self) { place in
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }

            place.title = data.title
            place.description = data.description
            place.latitude = data.latitude
            place.longitude = data.longitude
            place.isPublic = data.isPublic
            place.dateUpdate = Date()

            return place.save(on: request)
        }
    }

    /// Удаление места
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Place.self).flatMap(to: HTTPStatus.self) { place in
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }

            return place.delete(on: request).transform(to: .noContent)
        }
    }
    
}
