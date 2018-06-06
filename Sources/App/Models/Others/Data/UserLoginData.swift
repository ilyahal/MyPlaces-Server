import Vapor

/// Информация о попытке входа пользователя
struct UserLoginData: Content {
    
    /// Никнейм
    let username: String
    /// Пароль
    let password: String
    
}
