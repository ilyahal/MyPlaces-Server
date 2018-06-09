
/// Данные для отображения на странице регистрации
struct RegistrationContext: Encodable {
    
    // MARK: - Публичные свойства
    
    /// Имя
    let name: String?
    /// Адрес электронной почты
    let email: String?
    /// Никнейм
    let username: String?
    /// Произошла ошибка
    let registrationError: Bool
    
}


// MARK: - Context

extension RegistrationContext: Context { }
