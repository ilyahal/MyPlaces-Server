
/// Данные для отображения на странице рекомендаций
struct RecommendationsContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Категории
    let categories: [Category]
    /// Места
    let places: [Place]?
    
}


// MARK: - Context

extension RecommendationsContext: Context { }
