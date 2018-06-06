
/// Данные для отображения на странице списка
struct ListContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Список
    let list: List
    /// Места
    let places: [Place]
    
}
