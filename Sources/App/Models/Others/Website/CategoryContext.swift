
/// Данные для отображения на странице со списком мест из категории
struct CategoryContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Категория
    let category: Category
    /// Места
    let places: [Place]
    
}


// MARK: - Context

extension CategoryContext: Context { }
