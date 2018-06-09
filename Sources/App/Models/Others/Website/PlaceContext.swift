
/// Данные для отображения на странице места
struct PlaceContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Список
    let list: List
    /// Место
    let place: Place
    /// Категории
    let categories: [Category]
    
}


// MARK: - Context

extension PlaceContext: Context { }
