import Vapor

/// Информация об изображении
struct ImageCreateData: Codable {
    
    // MARK: - Публичные свойства
    
    /// Изображение
    let file: File
    
}


// MARK: - Content

extension ImageCreateData: Content { }
