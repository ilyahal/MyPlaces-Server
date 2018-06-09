import Vapor
import Authentication
import Leaf
import CoreLocation

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
        
        // Страница с категориями
        protectedRoutes.get("categories", use: categoriesHandler)
        
        // Страница с местами из категории
        protectedRoutes.get("categories", Category.parameter, use: categoryHandler)
        
        // Страница места из категории
        protectedRoutes.get("categories", Category.parameter, "places", Place.parameter, use: categoryPlaceHandler)
        
        // Страница с пользователями
        protectedRoutes.get("users", use: usersHandler)
        
        // Страница пользователя
        protectedRoutes.get("users", User.parameter, use: userHandler)
        
        // Страница места из категории
        protectedRoutes.get("users", User.parameter, "places", Place.parameter, use: userPlaceHandler)
        
        // Страница рекомендаций
        protectedRoutes.get("recommendations", use: recommendationsHandler)
        // Обработчик формы фильтров рекомендаций
        protectedRoutes.post(RecommendationsWebsiteData.self, at: "recommendations", use: recommendationsPostHandler)
        
        // Страница профиля
        protectedRoutes.get("profile", use: profileHandler)
        // Обработчик формы изменения профиля
        protectedRoutes.post(UserUpdateData.self, at: "profile", use: profilePostHandler)
    }
    
}


// MARK: - Приватные методы

private extension WebsiteController {
    
    /// Страница авторизации
    func loginHandler(_ request: Request) throws -> Future<View> {
        let username = request.query[String.self, at: "username"]
        let loginError = request.query[Bool.self, at: "error"] ?? false
        
        let context = LoginContext(username: username, loginError: loginError)
        let container = ContextContainer(title: "Вход", data: context, on: request)
        
        return try request.view().render("login", container)
    }
    
    /// Обработчик страницы авторизации
    func loginPostHandler(_ request: Request, data: UserLoginData) throws -> Future<Response> {
        let verifier = try request.make(BCryptDigest.self)
        return User.authenticate(username: data.username, password: data.password, using: verifier, on: request).map(to: Response.self) { user in
            guard let user = user else { return request.redirect(to: "/login?username=\(data.username)&error=true") }
            
            try request.authenticateSession(user)
            return request.redirect(to: "/")
        }
    }
    
    /// Страница регистрации
    func registrationHandler(_ request: Request) throws -> Future<View> {
        let name = request.query[String.self, at: "name"]
        let email = request.query[String.self, at: "email"]
        let username = request.query[String.self, at: "username"]
        let registrationError = request.query[Bool.self, at: "error"] ?? false
        
        let context = RegistrationContext(name: name, email: email, username: username, registrationError: registrationError)
        let container = ContextContainer(title: "Регистрация", data: context, on: request)
        
        return try request.view().render("registration", container)
    }
    
    /// Обработчик страницы регистрации
    func registrationPostHandler(_ request: Request, data: UserCreateData) throws -> Future<Response> {
        do {
            try data.validate()
        } catch {
            return Future.map(on: request) {
                request.redirect(to: "/registration?name=\(data.name)&email=\(data.email)&username=\(data.username)&error=true")
            }
        }
        
        let password = try BCrypt.hash(data.password)
        let user = User(name: data.name, username: data.username, password: password, email: data.email, photoUrl: nil)
        
        return user.save(on: request).map(to: Response.self) { savedUser in
            try request.authenticateSession(savedUser)
            return request.redirect(to: "/")
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
            let context = IndexContext(lists: lists)
            let container = ContextContainer(title: "Главная", menuActiveItemIndex: 0, data: context, on: request)
            
            return try request.view().render("index", container)
        }
    }
    
    /// Страница создания списка
    func createListHandler(_ request: Request) throws -> Future<View> {
        let context = CreateListContext()
        let container = ContextContainer(title: "Создание списка", data: context, on: request)
        
        return try request.view().render("createList", container)
    }
    
    /// Обработчик формы создания списка
    func createListPostHandler(_ request: Request, data: ListData) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        
        let description = (data.description ?? "").isEmpty ? nil : data.description
        let list = try List(title: data.title, description: description, dateInsert: Date(), userID: user.requireID())
        
        return list.save(on: request).map(to: Response.self) { savedList in
            return try request.redirect(to: "/lists/\(savedList.requireID())")
        }
    }
    
    /// Страница редактирования списка
    func editListHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let context = EditListContext(list: list)
            let container = ContextContainer(title: "Изменение списка", data: context, on: request)
            
            return try request.view().render("editList", container)
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
            
            return try list.save(on: request).transform(to: request.redirect(to: "/lists/\(list.requireID())"))
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
                let context = ListContext(list: list, places: places)
                let container = ContextContainer(title: list.title, data: context, on: request)
                
                return try request.view().render("list", container)
            }
        }
    }
    
    /// Страница создания места
    func createPlaceHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(List.self).flatMap(to: View.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            let context = CreatePlaceContext(list: list)
            let container = ContextContainer(title: "Создание места", data: context, on: request)
            
            return try request.view().render("createPlace", container)
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
                
                return try saves.flatten(on: request).transform(to: request.redirect(to: "/lists/\(savedPlace.listID)/places/\(savedPlace.requireID())"))
            }
        }
    }
    
    /// Страница редактирования места
    func editPlaceHandler(_ request: Request) throws -> Future<View> {
        return try flatMap(to: View.self, request.parameters.next(List.self), request.parameters.next(Place.self)) { list, place in
            guard place.listID == list.id else { throw Abort(.forbidden) }
            
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            return try place.categories.query(on: request).all().flatMap(to: View.self) { categories in
                let context = EditPlaceContext(list: list, place: place, categories: categories)
                let container = ContextContainer(title: "Изменение места", data: context, on: request)
                
                return try request.view().render("editPlace", container)
            }
        }
    }
    
    /// Обработчик формы редактирования места
    func editPlacePostHandler(_ request: Request, data: PlaceWebsiteData) throws -> Future<Response> {
        return try flatMap(to: Response.self, request.parameters.next(List.self), request.parameters.next(Place.self)) { list, place in
            guard place.listID == list.id else { throw Abort(.forbidden) }
            
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            place.title = data.title
            place.description = (data.description ?? "").isEmpty ? nil : data.description
            place.latitude = data.latitude
            place.longitude = data.longitude
            place.isPublic = data.isPublic != nil
            place.dateUpdate = Date()
            
            return try flatMap(to: Response.self, place.save(on: request), place.categories.query(on: request).all()) { savedPlace, existingCategories in
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
                
                return try does.flatten(on: request).transform(to: request.redirect(to: "/lists/\(place.listID)/places/\(place.requireID())"))
            }
        }
    }
    
    /// Обработчик формы удаления места
    func deletePlacePostHandler(_ request: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, request.parameters.next(List.self), request.parameters.next(Place.self)) { list, place in
            guard place.listID == list.id else { throw Abort(.forbidden) }
            
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            return try Place.deletePlace(place, on: request).transform(to: request.redirect(to: "/lists/\(place.listID)"))
        }
    }
    
    /// Страница с местом
    func placeHandler(_ request: Request) throws -> Future<View> {
        return try flatMap(to: View.self, request.parameters.next(List.self), request.parameters.next(Place.self)) { list, place in
            guard place.listID == list.id else { throw Abort(.forbidden) }
            
            let user = try request.requireAuthenticated(User.self)
            guard place.userID == user.id else { throw Abort(.forbidden) }
            
            return try place.categories.query(on: request).all().flatMap(to: View.self) { categories in
                let context = PlaceContext(list: list, place: place, categories: categories)
                let container = ContextContainer(title: place.title, data: context, on: request)
                
                return try request.view().render("place", container)
            }
        }
    }
    
    /// Страница с категориями
    func categoriesHandler(_ request: Request) throws -> Future<View> {
        return Category.query(on: request).all().flatMap(to: View.self) { categories in
            let context = CategoriesContext(categories: categories)
            let container = ContextContainer(title: "Категории", menuActiveItemIndex: 1, data: context, on: request)
            
            return try request.view().render("categories", container)
        }
    }
    
    /// Страница с местами из категории
    func categoryHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(Category.self).flatMap(to: View.self) { category in
            let user = try request.requireAuthenticated(User.self)
            
            let publicFilter: ModelFilter<Place> = try \.isPublic == true
            let selfPlaceFilter: ModelFilter<Place> = try \.userID == user.id
            
            return try category.places.query(on: request).group(.or) { or in
                or.filter(publicFilter)
                or.filter(selfPlaceFilter)
            }.all().flatMap(to: View.self) { places in
                let context = CategoryContext(category: category, places: places)
                let container = ContextContainer(title: category.title, data: context, on: request)
                
                return try request.view().render("category", container)
            }
        }
    }
    
    /// Страница места из категории
    func categoryPlaceHandler(_ request: Request) throws -> Future<View> {
        return try flatMap(to: View.self, request.parameters.next(Category.self), request.parameters.next(Place.self)) { category, place in
            let user = try request.requireAuthenticated(User.self)
            if place.userID != user.id && !place.isPublic {
                throw Abort(.forbidden)
            }
            
            return try flatMap(to: View.self, place.categories.query(on: request).all(), place.user.get(on: request)) { categories, placeCreator in
                let context = CategoryPlaceContext(category: category, place: place, categories: categories, user: placeCreator)
                let container = ContextContainer(title: place.title, data: context, on: request)
                
                return try request.view().render("categoryPlace", container)
            }
        }
    }
    
    /// Страница с пользователями
    func usersHandler(_ request: Request) throws -> Future<View> {
        return User.query(on: request).all().flatMap(to: View.self) { users in
            let context = UsersContext(users: users)
            let container = ContextContainer(title: "Пользователи", menuActiveItemIndex: 2, data: context, on: request)
            
            return try request.view().render("users", container)
        }
    }
    
    /// Страница пользователя
    func userHandler(_ request: Request) throws -> Future<View> {
        return try request.parameters.next(User.self).flatMap(to: View.self) { user in
            let publicFilter: ModelFilter<Place> = try \.isPublic == true
            return try user.places.query(on: request).filter(publicFilter).all().flatMap(to: View.self) { places in
                let context = UserContext(user: user, places: places)
                let container = ContextContainer(title: user.username, data: context, on: request)
                
                return try request.view().render("user", container)
            }
        }
    }
    
    /// Страница места пользователя
    func userPlaceHandler(_ request: Request) throws -> Future<View> {
        return try flatMap(to: View.self, request.parameters.next(User.self), request.parameters.next(Place.self)) { user, place in
            if place.userID != user.id && !place.isPublic {
                throw Abort(.forbidden)
            }
            
            return try place.categories.query(on: request).all().flatMap(to: View.self) { categories in
                let context = UserPlaceContext(user: user, place: place, categories: categories)
                let container = ContextContainer(title: place.title, data: context, on: request)
                
                return try request.view().render("userPlace", container)
            }
        }
    }
    
    /// Получить страницу рекомендаций
    func getRecommendationsView(with places: [Place]?, on request: Request) throws -> Future<View> {
        return Category.query(on: request).all().flatMap(to: View.self) { categories in
            let context = RecommendationsContext(categories: categories, places: places)
            let container = ContextContainer(title: "Рекомендации", menuActiveItemIndex: 3, data: context, on: request)
            
            return try request.view().render("recommendations", container)
        }
    }
    
    /// Страница рекомендаций
    func recommendationsHandler(_ request: Request) throws -> Future<View> {
        return try getRecommendationsView(with: nil, on: request)
    }
    
    /// Обработчик формы фильтров рекомендаций
    func recommendationsPostHandler(_ request: Request, data: RecommendationsWebsiteData) throws -> Future<View> {
        let user = try request.requireAuthenticated(User.self)
        let target = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        let distanceInMeters = data.distance * 1000
        let includeOwned = data.includeOwned != nil
        let categoryId = Int(data.category) ?? -1
        
        return try Category.find(categoryId, on: request).flatMap(to: View.self) { category in
            let recommendationsService = try request.make(RecommendationsService.self)
            return try recommendationsService.getRecommendations(for: user, target: target, distanceInMeters: distanceInMeters, category: category, includeOwned: includeOwned, on: request).flatMap(to: View.self) { recommendedPlaces in
                return try self.getRecommendationsView(with: recommendedPlaces, on: request)
            }
        }
    }
    
    /// Страница профиля
    func profileHandler(_ request: Request) throws -> Future<View> {
        let user = try request.requireAuthenticated(User.self)
        
        let name = request.query[String.self, at: "name"]
        let email = request.query[String.self, at: "email"]
        let profileError = request.query[Bool.self, at: "error"] ?? false
        
        let context = ProfileContext(user: user, name: name, email: email, profileError: profileError)
        let container = ContextContainer(title: "Профиль", data: context, on: request)
        
        return try request.view().render("profile", container)
    }
    
    /// Обработчик формы изменения профиля
    func profilePostHandler(_ request: Request, data: UserUpdateData) throws -> Future<Response> {
        do {
            try data.validate()
        } catch {
            return Future.map(on: request) {
                request.redirect(to: "/profile?name=\(data.name)&email=\(data.email)&error=true")
            }
        }
        
        let user = try request.requireAuthenticated(User.self)
        
        user.name = data.name
        user.email = data.email
        
        return user.save(on: request).transform(to: request.redirect(to: "/profile"))
    }
    
}
