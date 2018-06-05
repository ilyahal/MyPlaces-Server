import Vapor
import Fluent

/// Работа с категориями
struct ImagesController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "images"
        let imagesRoutes = router.grouped("images")
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = imagesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Создание изображения
        tokenAuthGroup.post(ImageCreateData.self, use: createHandler)
    }

}


// MARK: - Приватные методы

private extension ImagesController {
    
    /// Создание изображения
    func createHandler(_ request: Request, data: ImageCreateData) throws -> Future<Image> {
        let settingsService = try request.make(SettingsService.self)
        
        guard let contentType = data.file.contentType, data.file.data.count < settingsService.maxFileSize, settingsService.allowedContentType.contains(where: { $0.hashValue == contentType.hashValue }) else { throw Abort(.badRequest) }
        let filename = UUID().uuidString + "." + contentType.subType
        let user = try request.requireAuthenticated(User.self)
        let image = try Image(name: filename, dateInsert: Date(), userID: user.requireID())
        
        return image.save(on: request).map(to: Image.self) { savedImage in
            let filePath = settingsService.filesDirectory.appendingPathComponent(filename)
            try? data.file.data.write(to: filePath)
            
            return savedImage
        }
    }
    
}
