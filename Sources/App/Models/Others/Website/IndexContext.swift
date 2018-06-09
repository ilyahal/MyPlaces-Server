
/// Данные для отображения на главной странице
struct IndexContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Списки
    let lists: [List]
    
}


// MARK: - Context

extension IndexContext: Context { }
