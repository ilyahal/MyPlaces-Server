import Vapor

/// Информация об изображении
struct ImageCreateData: Content {
    
    /// Изображение
    var file: File
    
}
