import Vapor
import Fluent

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
        // Получение категорий места
        tokenAuthGroup.get(Place.parameter, "categories", use: getCategoriesHandler)
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
    
    /// Получение категорий места
    func getCategoriesHandler(_ request: Request) throws -> Future<[Category]> {
        return try request.parameters.next(Place.self).flatMap(to: [Category].self) { place in
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            return try place.categories.query(on: request).all()
        }
    }
    
    /// Создание места
    func createHandler(_ request: Request, data: PlaceData) throws -> Future<Place> {
        return try request.parameters.next(List.self).flatMap(to: Place.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let place = try Place(title: data.title, description: data.description, latitude: data.latitude, longitude: data.longitude, isPublic: data.isPublic, dateInsert: Date(), listID: list.requireID(), userID: user.requireID())
            return place.save(on: request).flatMap(to: Place.self) { savedPlace in
                var saves: [Future<Void>] = []
                for category in data.categories ?? [] {
                    let savePivot = try Category.addCategory(category, to: savedPlace, on: request)
                    saves.append(savePivot)
                }
                
                return saves.flatten(on: request).transform(to: savedPlace)
            }
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

            return place.save(on: request).flatMap(to: Place.self) { savedPlace in
                return try savedPlace.categories.query(on: request).all().flatMap(to: Place.self) { existingCategories in
                    let existingCategoriesTitles = Set<String>(existingCategories.map { $0.title })
                    let newCategoriesTitles = Set<String>(data.categories ?? [])
                    
                    let categoriesToAdd = newCategoriesTitles.subtracting(existingCategoriesTitles)
                    let categoriesToRemove = existingCategoriesTitles.subtracting(newCategoriesTitles)
                    
                    var does: [Future<Void>] = []
                    for newCategory in categoriesToAdd {
                        let savePivot = try Category.addCategory(newCategory, to: savedPlace, on: request)
                        does.append(savePivot)
                    }
                    
                    for categoryTitleToRemove in categoriesToRemove {
                        let categoryToRemove = existingCategories.first { $0.title == categoryTitleToRemove }
                        if let category = categoryToRemove {
                            let deletePivot = try PlaceCategoryPivot.deletePivot(for: savedPlace, with: category, on: request)
                            does.append(deletePivot)
                        }
                    }
                    
                    return does.flatten(on: request).transform(to: savedPlace)
                }
            }
        }
    }

    /// Удаление места
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Place.self).flatMap(to: HTTPStatus.self) { place in
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }

            return try Place.deletePlace(place, on: request).transform(to: .ok)
        }
    }
    
}
