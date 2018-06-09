
/// Данные для отображения на странице с категориями
struct CategoriesContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Категории
    let categories: [Category]
    
}


// MARK: - Context

extension CategoriesContext: Context { }
