
/// Данные для отображения на странице профиля
struct ProfileContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Пользователь
    let user: User
    /// Имя
    let name: String?
    /// Адрес электронной почты
    let email: String?
    /// Произошла ошибка
    let profileError: Bool
    
}
