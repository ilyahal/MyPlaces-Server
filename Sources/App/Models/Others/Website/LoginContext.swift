
/// Данные для отображения на странице авторизации
struct LoginContext: Context {
    
    /// Никнейм
    var username: String?
    /// Произошла ошибка
    let loginError: Bool
    
}
