
/// Данные для отображения на странице списка
struct ListContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Список
    let list: List
    /// Места
    let places: [Place]
    
}


// MARK: - Context

extension ListContext: Context { }
