import Vapor

/// Настройки
struct SettingsService: Service { }


// MARK: - Публичные свойства

extension SettingsService {
    
    /// Путь к папке с файлами пользователей
    var filesDirectory: URL {
        let directory = DirectoryConfig.detect()
        let workingDirectory = URL(fileURLWithPath: directory.workDir)
        let publicDirectory = workingDirectory.appendingPathComponent("Public", isDirectory: true)
        let filesDirectory = publicDirectory.appendingPathComponent("files", isDirectory: true)
        
        return filesDirectory
    }
    
    /// Максимальный размер изображения
    var maxFileSize: Int {
        return 20 * 1024 * 1024
    }
    
    /// Допустимые типы файлов
    var allowedContentType: [MediaType] {
        return [.jpeg, .png]
    }
    
    /// URL к папке "files"
    var filesUrl: URL {
        guard let filesUrl = URL(string: "http://5.23.49.21/files/") else { preconditionFailure() }
        return filesUrl
    }
    
}
