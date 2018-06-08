
/// Данные для отображения на странице места из категории
struct CategoryPlaceContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Категория
    let category: Category
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    /// Пользователь
    let user: User
    
}
