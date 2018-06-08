
/// Данные для отображения на странице со списком мест из категории
struct CategoryContext: Context {
    
    // MARK: - Публичные свойства
    
    /// Категория
    let category: Category
    /// Места
    let places: [Place]
    
}
