
/// Данные для отображения на странице с категориями
struct CategoriesContext: Context {
    
    // MARK: - Публичные свойства
    
    let title: String
    /// Индекс активного элемента меню
    let navActiveItemIndex: Int
    /// Категории
    let categories: [Category]
    
}
