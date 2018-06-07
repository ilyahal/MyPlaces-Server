
/// Данные для отображения на странице места
struct PlaceContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Список
    let list: List
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    
}
