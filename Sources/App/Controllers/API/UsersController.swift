import Vapor
import Crypto
import Authentication

/// Работа с пользователями
struct UsersController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "users"
        let usersRoutes = router.grouped("users")
        
        // Получение всех пользователей
        usersRoutes.get(use: getAllHandler)
        // Получение пользователя
        usersRoutes.get(User.parameter, use: getHandler)
        // Создание пользователя
        usersRoutes.post(UserCreateData.self, use: createHandler)
        
        // Группа методов, защищенных входом по паролю
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoutes.grouped(basicAuthMiddleware)
        
        // Авторизация пользователя
        basicAuthGroup.post("login", use: loginHandler)
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Редактирование информации о пользователе
        tokenAuthGroup.put(UserUpdateData.self, use: updateHandler)
        // Деавторизация пользователя
        tokenAuthGroup.delete(use: logoutHandler)
    }
    
}


// MARK: - Приватные методы

private extension UsersController {
    
    /// Получение всех пользователей
    func getAllHandler(_ request: Request) throws -> Future<[User.Public]> {
        return User.query(on: request).decode(User.Public.self).all()
    }
    
    /// Получение пользователя
    func getHandler(_ request: Request) throws -> Future<User.Public> {
        return try request.parameters.next(User.self).convertToPublic()
    }
    
    /// Создание пользователя
    func createHandler(_ request: Request, data: UserCreateData) throws -> Future<User.Public> {
        let password = try BCrypt.hash(data.password)
        let user = User(name: data.name, username: data.username, password: password, email: data.email, photoUrl: nil)
        
        return user.save(on: request).convertToPublic()
    }
    
    /// Авторизация пользователя
    func loginHandler(_ request: Request) throws -> Future<Token> {
        let user = try request.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        
        return token.save(on: request)
    }
    
    /// Редактирование информации о пользователе
    func updateHandler(_ request: Request, data: UserUpdateData) throws -> Future<User.Public> {
        let user = try request.requireAuthenticated(User.self)
        
        var photoUrl: URL? = nil
        if let photoName = data.photoName {
            let settingsService = try request.make(SettingsService.self)
            photoUrl = settingsService.filesUrl.appendingPathComponent(photoName)
        }
        
        user.name = data.name
        user.email = data.email
        user.photoUrl = photoUrl?.absoluteString
        
        return user.update(on: request).convertToPublic()
    }
    
    /// Деавторизация пользователя
    func logoutHandler(_ request: Request) throws -> Future<HTTPStatus> {
        let token = try request.requireAuthenticated(Token.self)
        return token.delete(on: request).transform(to: .ok)
    }
    
}
