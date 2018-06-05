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
        usersRoutes.get(User.Public.parameter, use: getHandler)
        // Создание пользователя
        usersRoutes.post(User.self, use: createHandler)
        
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
        return User.Public.query(on: request).all()
    }
    
    /// Получение пользователя
    func getHandler(_ request: Request) throws -> Future<User.Public> {
        return try request.parameters.next(User.Public.self)
    }
    
    /// Создание пользователя
    func createHandler(_ request: Request, user: User) throws -> Future<User.Public> {
        return try User.query(on: request).filter(\.username == user.username).first().flatMap(to: User.Public.self) { existingUser in
            guard existingUser == nil else { throw Abort(.badRequest, reason: "Another user already exists in the system with the same login name.") }
            
            let hasher = try request.make(BCryptDigest.self)
            user.password = try hasher.hash(user.password)
            
            return user.save(on: request).flatMap(to: User.Public.self) { user in
                return try User.Public.find(user.requireID(), on: request).map(to: User.Public.self) { userPublic in
                    guard let userPublic = userPublic else { throw Abort(.internalServerError) }
                    return userPublic
                }
            }
        }
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
        
        user.name = data.name
        user.email = data.email
        
        return user.update(on: request).flatMap(to: User.Public.self) { user in
            return try User.Public.find(user.requireID(), on: request).map(to: User.Public.self) { userPublic in
                guard let userPublic = userPublic else { throw Abort(.internalServerError) }
                return userPublic
            }
        }
    }
    
    /// Деавторизация пользователя
    func logoutHandler(_ request: Request) throws -> HTTPStatus {
        try request.unauthenticate(User.self) // FIXME: Не работает деавторизация, открыл issue на github: https://github.com/vapor/auth/issues/45
        return .ok
    }
    
}
