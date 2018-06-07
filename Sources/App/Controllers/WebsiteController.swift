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
        
        // Страница создания места
        protectedRoutes.get("lists", List.parameter, "places", "create", use: createPlaceHandler)
        // Обработчик формы создания места
        protectedRoutes.post(PlaceWebsiteData.self, at: "lists", List.parameter, "places", "create", use: createPlacePostHandler)
        
        // Страница редактирования места
        protectedRoutes.get("lists", List.parameter, "places", Place.parameter, "edit", use: editPlaceHandler)
        // Обработчик формы редактирования места
        protectedRoutes.post(PlaceWebsiteData.self, at: "lists", List.parameter, "places", Place.parameter, "edit", use: editPlacePostHandler)
        
        // Обработчик формы удаления места
        protectedRoutes.post("lists", List.parameter, "places", Place.parameter, "delete", use: deletePlacePostHandler)
        
        // Страница с местом
        protectedRoutes.get("lists", List.parameter, "places", Place.parameter, use: placeHandler)
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
        
        let description = (data.description ?? "").isEmpty ? nil : data.description
        let list = try List(title: data.title, description: description, dateInsert: Date(), userID: user.requireID())
        
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
            list.description = (data.description ?? "").isEmpty ? nil : data.description
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
    
    /// Страница создания места
    func createPlaceHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let context = CreatePlaceContext(title: "Создание места", list: list)
            return try request.view().render("createPlace", context)
        }
    }
    
    /// Обработчик формы создания места
    func createPlacePostHandler(_ request: Request, data: PlaceWebsiteData) throws -> Future<Response> {
        return try request.parameters.next(List.self).flatMap(to: Response.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let description = (data.description ?? "").isEmpty ? nil : data.description
            let place = try Place(title: data.title, description: description, latitude: data.latitude, longitude: data.longitude, photoUrl: nil, isPublic: data.isPublic != nil, dateInsert: Date(), listID: list.requireID(), userID: user.requireID())
            return place.save(on: request).flatMap(to: Response.self) { savedPlace in
                var saves: [Future<Void>] = []
                for category in data.categories ?? [] {
                    let savePivot = try Category.addCategory(category, to: savedPlace, on: request)
                    saves.append(savePivot)
                }
                
                return saves.flatten(on: request).transform(to: request.redirect(to: "/lists/\(savedPlace.listID)"))
            }
        }
    }
    
    /// Страница редактирования места
    func editPlaceHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            return try request.parameters.next(Place.self).flatMap(to: View.self) { place in
                guard place.listID == list.id else { throw Abort(.forbidden) }
                
                let user = try request.requireAuthenticated(User.self)
                guard place.userID == user.id else { throw Abort(.forbidden) }
                
                return try place.categories.query(on: request).all().flatMap(to: View.self) { categories in
                    let context = EditPlaceContext(title: "Изменение места", list: list, place: place, categories: categories)
                    return try request.view().render("editPlace", context)
                }
            }
        }
    }
    
    /// Обработчик формы редактирования места
    func editPlacePostHandler(_ request: Request, data: PlaceWebsiteData) throws -> Future<Response> {
        return try request.parameters.next(List.self).flatMap(to: Response.self) { list in
            return try request.parameters.next(Place.self).flatMap(to: Response.self) { place in
                guard place.listID == list.id else { throw Abort(.forbidden) }
                
                let user = try request.requireAuthenticated(User.self)
                guard place.userID == user.id else { throw Abort(.forbidden) }
                
                place.title = data.title
                place.description = (data.description ?? "").isEmpty ? nil : data.description
                place.latitude = data.latitude
                place.longitude = data.longitude
                place.isPublic = data.isPublic != nil
                place.dateUpdate = Date()
                
                return place.save(on: request).flatMap(to: Response.self) { savedPlace in
                    return try savedPlace.categories.query(on: request).all().flatMap(to: Response.self) { existingCategories in
                        let existingCategoriesTitles = Set<String>(existingCategories.map { $0.title })
                        let newCategoriesTitles = Set<String>(data.categories ?? [])
                        
                        let categoriesToAdd = newCategoriesTitles.subtracting(existingCategoriesTitles)
                        let categoriesToRemove = existingCategoriesTitles.subtracting(newCategoriesTitles)
                        
                        var does: [Future<Void>] = []
                        for newCategory in categoriesToAdd {
                            let savePivot = try Category.addCategory(newCategory, to: savedPlace, on: request)
                            does.append(savePivot)
                        }
                        
                        for categoryTitleToRemove in categoriesToRemove {
                            let categoryToRemove = existingCategories.first { $0.title == categoryTitleToRemove }
                            if let category = categoryToRemove {
                                let deletePivot = try PlaceCategoryPivot.deletePivot(for: savedPlace, with: category, on: request)
                                does.append(deletePivot)
                            }
                        }
                        
                        return does.flatten(on: request).transform(to: request.redirect(to: "/lists/\(place.listID)"))
                    }
                }
            }
        }
    }
    
    /// Обработчик формы удаления места
    func deletePlacePostHandler(_ request: Request) throws -> Future<Response> {
        return try request.parameters.next(List.self).flatMap(to: Response.self) { list in
            return try request.parameters.next(Place.self).flatMap(to: Response.self) { place in
                guard place.listID == list.id else { throw Abort(.forbidden) }
                
                let user = try request.requireAuthenticated(User.self)
                guard place.userID == user.id else { throw Abort(.forbidden) }
                
                return try Place.deletePlace(place, on: request).transform(to: request.redirect(to: "/lists/\(place.listID)"))
            }
        }
    }
    
    /// Страница с местом
    func placeHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            return try request.parameters.next(Place.self).flatMap(to: View.self) { place in
                guard place.listID == list.id else { throw Abort(.forbidden) }
                
                let user = try request.requireAuthenticated(User.self)
                guard place.userID == user.id else { throw Abort(.forbidden) }
                
                return try place.categories.query(on: request).all().flatMap(to: View.self) { categories in
                    let context = PlaceContext(title: place.title, list: list, place: place, categories: categories)
                    return try request.view().render("place", context)
                }
            }
        }
    }
    
}
