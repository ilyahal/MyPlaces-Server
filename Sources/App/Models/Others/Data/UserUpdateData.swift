import Vapor

/// Измененная информация о пользователе
struct UserUpdateData: Content {
    
    /// Имя
    let name: String
    /// Адрес электронной почты
    let email: String
    /// Название фотографии
    let photoName: String?
    
}


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
