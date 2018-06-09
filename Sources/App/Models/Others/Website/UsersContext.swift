
/// Данные для отображения на странице с пользователями
struct UsersContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Пользователи
    let users: [User]
    
}


// MARK: - Context

extension UsersContext: Context { }
