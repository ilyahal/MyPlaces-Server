import CoreLocation

/// Информация о месте
struct PlaceInfo {
    
    // MARK: - Публичные свойства
    
    /// Место
    let place: Place
    /// Дистанция до указанной точки
    let distanceToTarget: CLLocationDistance
    /// Дистанция до центральной точки пользовательских мест
    let distanceToCenter: CLLocationDistance
    /// Категории места
    let categoriesIds: Set<Category.ID>
    /// Место пользователя
    let isOwned: Bool
    
}
