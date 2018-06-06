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
        
        // Страница создания списка
        protectedRoutes.get("lists", "create", use: createListHandler)
        // Обработчик формы создания списка
        protectedRoutes.post(ListData.self, at: "lists", "create", use: createListPostHandler)
        
        // Страница редактирования списка
        protectedRoutes.get("lists", List.parameter, "edit", use: editListHandler)
        // Обработчик формы редактирования списка
        protectedRoutes.post(ListData.self, at: "lists", List.parameter, "edit", use: editListPostHandler)
        
        // Обработчик формы удаления списка
        protectedRoutes.post("lists", List.parameter, "delete", use: deleteListPostHandler)
        
        // Страница со списком
        protectedRoutes.get("lists", List.parameter, use: listHandler)
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
            let context = IndexContext(title: "Главная", navActiveItemIndex: 1, lists: lists)
            return try request.view().render("index", context)
        }
    }
    
    /// Страница создания списка
    func createListHandler(_ request: Request) throws -> Future<View> {
        let context = CreateListContext(title: "Создание списка")
        return try request.view().render("createList", context)
    }
    
    /// Обработчик формы создания списка
    func createListPostHandler(_ request: Request, data: ListData) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        let list = try List(title: data.title, description: data.description, dateInsert: Date(), userID: user.requireID())
        
        return list.save(on: request).transform(to: request.redirect(to: "/"))
    }
    
    /// Страница редактирования списка
    func editListHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let context = EditListContext(title: "Изменение списка", list: list)
            return try request.view().render("editList", context)
        }
    }
    
    /// Обработчик формы редактирования списка
    func editListPostHandler(_ request: Request, data: ListData) throws -> Future<Response> {
        return try request.parameters.next(List.self).flatMap(to: Response.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            list.title = data.title
            list.description = data.description
            list.dateUpdate = Date()
            
            return list.save(on: request).transform(to: request.redirect(to: "/"))
        }
    }
    
    /// Обработчик формы удаления списка
    func deleteListPostHandler(_ request: Request) throws -> Future<Response> {
        return try request.parameters.next(List.self).flatMap(to: Response.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            return try List.deleteList(list, on: request).transform(to: request.redirect(to: "/"))
        }
    }
    
    /// Страница со списком
    func listHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            return try list.places.query(on: request).all().flatMap(to: View.self) { places in
                let context = ListContext(title: list.title, list: list, places: places)
                return try request.view().render("list", context)
            }
        }
    }
    
}
