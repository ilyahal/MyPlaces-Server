import Vapor

/// Измененная информация о пользователе
struct UserUpdateData: Content {
    
    /// Имя
    var name: String
    /// Адрес электронной почты
    var email: String?
    
}
