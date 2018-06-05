import Vapor

/// Информация об изображении
struct ImageCreateData: Content {
    
    /// Изображение
    let file: File
    
}
