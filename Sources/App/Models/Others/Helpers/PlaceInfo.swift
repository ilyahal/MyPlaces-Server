
/// Информация о месте
struct PlaceInfo {
    
    // MARK: - Публичные свойства
    
    /// Место
    let place: Place
    /// Дистанция до указанной точки
    let distanceToTarget: LocationDistance
    /// Дистанция до центральной точки пользовательских мест
    let distanceToCenter: LocationDistance
    /// Категории места
    let categoriesIds: Set<Category.ID>
    /// Место пользователя
    let isOwned: Bool
    
}
