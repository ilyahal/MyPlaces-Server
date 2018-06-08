
/// Данные для отображения на странице редактирования места
struct EditPlaceContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Список
    let list: List
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    
}
