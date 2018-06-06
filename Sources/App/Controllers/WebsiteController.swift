import Vapor
import Authentication
import Leaf

/// Сайт
struct WebsiteController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов, сохраняющих аутентификацию и позволяющих выполнить ее лишь раз
        let authSessionsMiddleware = User.authSessionsMiddleware()
        let authSessionRoutes = router.grouped(authSessionsMiddleware)
        
        // Страница авторизации
        authSessionRoutes.get("login", use: loginHandler)
        // Обработчик страницы авторизации
        authSessionRoutes.post(UserLoginData.self, at: "login", use: loginPostHandler)
        
        // Страница регистрации
        authSessionRoutes.get("registration", use: registrationHandler)
        // Обработчик страницы регистрации
        authSessionRoutes.post(UserCreateData.self, at: "registration", use: registrationPostHandler)
        
        // Группа методов, выполняющих перенаправление на страницу авторизации, в случае отсутствия активной сессии
        let redirectMiddleware = RedirectMiddleware<User>(path: "/login")
        let protectedRoutes = authSessionRoutes.grouped(redirectMiddleware)
        
        // Обработчик формы выхода
        protectedRoutes.post("logout", use: logoutHandler)
        
        // Главная страница
        protectedRoutes.get(use: indexHandler)
    }
    
}


// MARK: - Приватные методы

private extension WebsiteController {
    
    /// Страница авторизации
    func loginHandler(_ request: Request) throws -> Future<View> {
        let context = LoginContext(title: "Вход")
        return try request.view().render("login", context)
    }
    
    /// Обработчик страницы авторизации
    func loginPostHandler(_ request: Request, data: UserLoginData) throws -> Future<Response> {
        let verifier = try request.make(BCryptDigest.self)
        return User.authenticate(username: data.username, password: data.password, using: verifier, on: request).map(to: Response.self) { user in
            guard let user = user else { return request.redirect(to: "/login") }
            
            try request.authenticateSession(user)
            return request.redirect(to: "/")
        }
    }
    
    /// Страница регистрации
    func registrationHandler(_ request: Request) throws -> Future<View> {
        let context = RegistrationContext(title: "Регистрация")
        return try request.view().render("registration", context)
    }
    
    /// Обработчик страницы регистрации
    func registrationPostHandler(_ request: Request, data: UserCreateData) throws -> Future<Response> {
        return try User.checkExisting(withUsername: data.username, on: request).flatMap(to: Response.self) { exist in
            guard !exist else { throw Abort(.badRequest) }
            
            let password = try User.createPassword(with: data.password, on: request)
            let user = User(name: data.name, username: data.username, password: password, email: data.email, photoUrl: nil)
            
            return user.save(on: request).transform(to: request.redirect(to: "/login"))
        }
    }
    
    /// Обработчик формы выхода
    func logoutHandler(_ request: Request) throws -> Response {
        try request.unauthenticateSession(User.self)
        return request.redirect(to: "/login")
    }
    
    /// Главная страница
    func indexHandler(_ request: Request) throws -> Future<View> {
        let user = try request.requireAuthenticated(User.self)
        return try user.lists.query(on: request).all().flatMap(to: View.self) { lists in
            let context = IndexContext(title: "Главная", lists: lists)
            return try request.view().render("index", context)
        }
    }
    
}
