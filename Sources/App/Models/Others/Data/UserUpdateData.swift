import Vapor

/// Измененная информация о пользователе
struct UserUpdateData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Имя
    let name: String
    /// Адрес электронной почты
    let email: String
    /// Название фотографии
    let photoName: String?
    
}


// MARK: - Content

extension UserUpdateData: Content { }


// MARK: - Reflectable

extension UserUpdateData: Reflectable { }


// MARK: - Validatable

extension UserUpdateData: Validatable {
    
    static func validations() throws -> Validations<UserUpdateData> {
        var validations = Validations(UserUpdateData.self)
        try validations.add(\.name, .ascii)
        try validations.add(\.email, .email)
        
        return validations
    }
    
}
