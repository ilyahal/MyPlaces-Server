
/// Данные для отображения на странице со списком мест пользователя
struct UserContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Пользователь
    let user: User
    /// Места
    let places: [Place]
    
}


// MARK: - Context

extension UserContext: Context { }
