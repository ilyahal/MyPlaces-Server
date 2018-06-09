
/// Данные для отображения на странице создания места
struct CreatePlaceContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Список
    let list: List
    
}


// MARK: - Context

extension CreatePlaceContext: Context { }
