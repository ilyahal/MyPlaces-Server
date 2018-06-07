
/// Данные для отображения на странице с пользователями
struct UsersContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Индекс активного элемента меню
    let navActiveItemIndex: Int
    /// Пользователи
    let users: [User]
    
}
