
/// Данные для отображения на странице места пользователя
struct UserPlaceContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Пользователь
    let user: User
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    
}
