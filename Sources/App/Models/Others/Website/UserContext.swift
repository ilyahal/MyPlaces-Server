
/// Данные для отображения на странице со списком мест пользователя
struct UserContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Пользователь
    let user: User
    /// Места
    let places: [Place]
    
}
