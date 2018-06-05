import Vapor

/// Измененная информация о пользователе
struct UserUpdateData: Content {
    
    /// Имя
    let name: String
    /// Адрес электронной почты
    let email: String?
    
}
