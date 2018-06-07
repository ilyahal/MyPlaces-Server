import Vapor

/// Информация о пользователе
struct UserCreateData: Content {
    
    /// Имя
    let name: String
    /// Никнейм
    let username: String
    /// Пароль
    let password: String
    /// Адрес электронной почты
    let email: String
    
}
