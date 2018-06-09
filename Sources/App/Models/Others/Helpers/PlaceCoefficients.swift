
/// Коэффициенты для места
struct PlaceCoefficients {
    
    // MARK: - Публичные свойства
    
    /// Место
    let place: Place
    /// Коэффициент дистанция до центральной точки пользовательских мест
    let distanceToCenter: Double
    /// Коэффициент совпадения категорий с категориями, куда сохраняет места пользователь
    let categoriesCoincidence: Double
    /// Коэффициент принадлежания места пользователю
    let owned: Double
    /// Коэффициент дистанция до указанной точки
    let distanceToTarget: Double
    
}
