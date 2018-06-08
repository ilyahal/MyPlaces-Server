
/// Данные для отображения на странице со списком мест пользователя
struct UserContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Пользователь
    let user: User
    /// Места
    let places: [Place]
    
}
