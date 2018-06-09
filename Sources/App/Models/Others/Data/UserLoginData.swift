import Vapor

/// Информация о попытке входа пользователя
struct UserLoginData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Никнейм
    let username: String
    /// Пароль
    let password: String
    
}


// MARK: - Content

extension UserLoginData: Content { }
