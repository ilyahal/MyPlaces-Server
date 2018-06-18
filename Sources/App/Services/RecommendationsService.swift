import Vapor
import Fluent

/// Рекомендации
struct RecommendationsService: Service { }


// MARK: - Публичные методы

extension RecommendationsService {
    
    /// Получить рекомендуемые точки
    func getRecommendations(for user: User, target coordinate: LocationCoordinate2D, distanceInMeters distance: LocationDistance, category: Category?, includeOwned: Bool, on request: Request) throws -> Future<[Place]> {
        
        // Получаем точки пользователя
        return try user.places.query(on: request).all().flatMap(to: [Place].self) { userPlaces in
            
            // Выходим, если рекомендаций нет
            guard !userPlaces.isEmpty else {
                return Future.map(on: request) { userPlaces }
            }
            
            // Рассчитываем центральную точку для всех точек пользователя
            let userPlacesCoordinates = self.getCoordinates(for: userPlaces)
            let centerCoordinate = self.getCenterCoordinate(for: userPlacesCoordinates)
            
            // Получаем категории в которых содержатся места пользователя
            return try self.getCategoriesIds(for: userPlaces, on: request).flatMap(to: [Place].self) { categoriesIds in
                
                // Получаем места, которые будут порекомендованы
                var placesQuery: QueryBuilder<Place, Place>
                if let category = category {
                     placesQuery = try category.places.query(on: request)
                } else {
                    placesQuery = Place.query(on: request)
                }
                
                let publicFilter: ModelFilter<Place> = try \.isPublic == true
                if includeOwned {
                    let selfPlaceFilter: ModelFilter<Place> = try \.userID == user.id
                    placesQuery = placesQuery.group(.or) { or in
                        or.filter(publicFilter)
                        or.filter(selfPlaceFilter)
                    }
                } else {
                    let notOwnedPlaceFilter: ModelFilter<Place> = try \.userID != user.id
                    placesQuery = placesQuery.filter(publicFilter).filter(notOwnedPlaceFilter)
                }
                
                return placesQuery.all().flatMap(to: [Place].self) { targetPlaces in
                    
                    // Подготовка отобранных мест
                    return try self.processPlaces(targetPlaces, target: coordinate, centerCoordinate: centerCoordinate, distance: distance, user: user, on: request).map(to: [Place].self) { placesInfo in
                        let placesCoefficients = self.calculateCoefficients(for: placesInfo, categoriesIds: categoriesIds, distance: distance)
                        let placesPriorities = self.calculatePriorities(for: placesCoefficients).sorted { $0.priority < $1.priority }
                        
                        return placesPriorities.map { $0.place }
                    }
                }
            }
        }
    }
}


// MARK: - Приватные методы

private extension RecommendationsService {
    
    /// Получить координаты места
    func getCoordinate(for place: Place) -> LocationCoordinate2D {
        return LocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    
    /// Получить координаты мест
    func getCoordinates(for places: [Place]) -> [LocationCoordinate2D] {
        return places.map { self.getCoordinate(for: $0) }
    }
    
    /// Получить центральную координату для координат
    func getCenterCoordinate(for coordinates: [LocationCoordinate2D]) -> LocationCoordinate2D {
        var x: Float = 0
        var y: Float = 0
        var z: Float = 0
        
        for coordinate in coordinates {
            let latitude = Float(deg2rad(coordinate.latitude))
            let longitude = Float(deg2rad(coordinate.longitude))
            
            x += cos(latitude) * cos(longitude)
            y += cos(latitude) * sin(longitude)
            z += sin(latitude)
        }
        
        let coordinatesCount = Float(coordinates.count)
        x /= coordinatesCount
        y /= coordinatesCount
        z /= coordinatesCount
        
        let longitude = atan2(y, x)
        let hypersphericalCoordinateSystem = sqrt(x * x + y * y)
        let latitude = atan2(z, hypersphericalCoordinateSystem)
        
        let resultLatitude = LocationDegrees(rad2deg(Double(latitude)))
        let resultLongitude = LocationDegrees(rad2deg(Double(longitude)))
        let result = LocationCoordinate2D(latitude: resultLatitude, longitude: resultLongitude)
        
        return result
    }
    
    /// Получить категории места
    func getCategories(for place: Place, on request: Request) throws -> Future<[Category]> {
        return try place.categories.query(on: request).all()
    }
    
    /// Получить идентификаторы категорий
    func getCategoriesIds(for categories: [Category]) throws -> Set<Category.ID> {
        let categoriesIds = try categories.map { try $0.requireID() }
        return Set(categoriesIds)
    }
    
    /// Получить идентификаторы категорий, к которым относятся места
    func getCategoriesIds(for places: [Place], on request: Request) throws -> Future<Set<Category.ID>> {
        let queried = try places.map { try self.getCategories(for: $0, on: request) }
        return queried.flatten(on: request).map(to: Set<Category.ID>.self) { categories in
            let categoriesIds = try categories.flatMap { try self.getCategoriesIds(for: $0) }
            return Set(categoriesIds)
        }
    }
    
    /// Получить расстояние между координатами
    func getDistance(from: LocationCoordinate2D, to: LocationCoordinate2D) -> LocationDistance {
        let theta = from.longitude - to.longitude
        
        var distance = sin(deg2rad(from.latitude)) * sin(deg2rad(to.latitude)) + cos(deg2rad(from.latitude)) * cos(deg2rad(to.latitude)) * cos(deg2rad(theta))
        distance = acos(distance)
        distance = rad2deg(distance)
        distance *= 60 * 1.1515
        distance *= 1.609344 // километры
        distance *= 1000 // метры
        
        return distance
    }
    
    /// Подготовка информации о месте
    func preparePlaceInfo(_ place: Place, target coordinate: LocationCoordinate2D, centerCoordinate: LocationCoordinate2D, distance: LocationDistance, user: User, on request: Request) throws -> Future<PlaceInfo>? {
        let placeCoordinate = self.getCoordinate(for: place)
        let distanceToTarget = self.getDistance(from: placeCoordinate, to: coordinate)
        let distanceToCenter = self.getDistance(from: placeCoordinate, to: centerCoordinate)
        
        guard distanceToTarget <= distance else { return nil }
        
        return try getCategories(for: place, on: request).map(to: PlaceInfo.self) { categories in
            let categoriesIds = try self.getCategoriesIds(for: categories)
            let isOwned = try place.userID == user.requireID()
            return PlaceInfo(place: place, distanceToTarget: distanceToTarget, distanceToCenter: distanceToCenter, categoriesIds: categoriesIds, isOwned: isOwned)
        }
    }
    
    /// Подготовка информации о местах
    func processPlaces(_ places: [Place], target coordinate: LocationCoordinate2D, centerCoordinate: LocationCoordinate2D, distance: LocationDistance, user: User, on request: Request) throws -> Future<[PlaceInfo]> {
        let prepares = try places.compactMap { try self.preparePlaceInfo($0, target: coordinate, centerCoordinate: centerCoordinate, distance: distance, user: user, on: request) }
        return prepares.flatten(on: request)
    }
    
    /// Рассчитать коэффициенты для места
    func calculateCoefficients(for placeInfo: PlaceInfo, categoriesIds: Set<Category.ID>, distance: LocationDistance, maximumDistanceToCenter: LocationDistance) -> PlaceCoefficients {
        let distanceToCenter: Double
        if maximumDistanceToCenter == 0 {
            distanceToCenter = 0
        } else {
            distanceToCenter = placeInfo.distanceToCenter / maximumDistanceToCenter
        }
        let categoriesCoincidence: Double
        if categoriesIds.count == 0 {
            categoriesCoincidence = 0
        } else {
            categoriesCoincidence = Double(categoriesIds.subtracting(placeInfo.categoriesIds).count) / Double(categoriesIds.count)
        }
        let owned: Double = placeInfo.isOwned ? 0 : 1
        let distanceToTarget: Double
        if distance == 0 {
            distanceToTarget = 0
        } else {
            distanceToTarget = placeInfo.distanceToTarget / distance
        }
        
        return PlaceCoefficients(place: placeInfo.place, distanceToCenter: distanceToCenter, categoriesCoincidence: categoriesCoincidence, owned: owned, distanceToTarget: distanceToTarget)
    }
    
    /// Рассчитать коэффициенты для мест
    func calculateCoefficients(for placesInfo: [PlaceInfo], categoriesIds: Set<Category.ID>, distance: LocationDistance) -> [PlaceCoefficients] {
        let maximumDistanceToCenter = placesInfo.map { $0.distanceToCenter }.max() ?? 0
        return placesInfo.map { calculateCoefficients(for: $0, categoriesIds: categoriesIds, distance: distance, maximumDistanceToCenter: maximumDistanceToCenter) }
    }
    
    /// Рассчитить приоритеты для мест
    func calculatePriorities(for placesCoefficients: [PlaceCoefficients]) -> [PlacePriority] {
        return placesCoefficients.map {
            let priority = ($0.distanceToCenter * 0.1 + $0.categoriesCoincidence * 0.2 + $0.owned * 0.3 + $0.distanceToTarget * 0.4) / 4
            return PlacePriority(place: $0.place, priority: priority)
        }
    }
    
}
