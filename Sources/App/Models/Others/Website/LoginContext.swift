
/// Данные для отображения на странице авторизации
struct LoginContext: Encodable {
    
    /// Никнейм
    var username: String?
    /// Произошла ошибка
    let loginError: Bool
    
}


// MARK: - Context

extension LoginContext: Context { }
