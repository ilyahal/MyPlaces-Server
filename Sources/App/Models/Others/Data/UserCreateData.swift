import Vapor

/// Информация о пользователе
struct UserCreateData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Имя
    let name: String
    /// Адрес электронной почты
    let email: String
    /// Никнейм
    let username: String
    /// Пароль
    let password: String
    
}


// MARK: - Content

extension UserCreateData: Content { }


// MARK: - Reflectable

extension UserCreateData: Reflectable { }


// MARK: - Validatable

extension UserCreateData: Validatable {
    
    static func validations() throws -> Validations<UserCreateData> {
        var validations = Validations(UserCreateData.self)
        try validations.add(\.name, .ascii)
        try validations.add(\.email, .email)
        try validations.add(\.username, .alphanumeric && .count(3...))
        try validations.add(\.password, .alphanumeric && .count(6...))
        
        return validations
    }
    
}
