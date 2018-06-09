
/// Данные для отображения на странице редактирования списка
struct EditListContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Список
    let list: List
    
}


// MARK: - Context

extension EditListContext: Context { }
