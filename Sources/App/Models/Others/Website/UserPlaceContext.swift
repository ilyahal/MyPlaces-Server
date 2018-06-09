
/// Данные для отображения на странице места пользователя
struct UserPlaceContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Пользователь
    let user: User
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    
}


// MARK: - Context

extension UserPlaceContext: Context { }
