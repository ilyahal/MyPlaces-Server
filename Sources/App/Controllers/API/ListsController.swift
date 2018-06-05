import Vapor

/// Работа со списками
struct ListsController: RouteCollection {
    
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        
        // Группа методов "lists"
        let listsRoutes = router.grouped("lists")
        
        // Группа методов, защищенных входом по токену
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = listsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        // Получение всех списков пользователя
        tokenAuthGroup.get(use: getAllHandler)
        // Получение списка
        tokenAuthGroup.get(List.parameter, use: getHandler)
        // Создание списка
        tokenAuthGroup.post(ListData.self, use: createHandler)
        // Изменение списка
        tokenAuthGroup.put(ListData.self, at: List.parameter, use: updateHandler)
        // Удаление списка
        tokenAuthGroup.delete(List.parameter, use: deleteHandler)
    }
    
}


// MARK: - Приватные методы

private extension ListsController {
    
    /// Получение всех списков пользователя
    func getAllHandler(_ request: Request) throws -> Future<[List]> {
        let user = try request.requireAuthenticated(User.self)
        return try user.lists.query(on: request).all() // TODO: Сортировка
    }
    
    /// Получение списка
    func getHandler(_ request: Request) throws -> Future<List> {
        return try request.parameters.next(List.self).map(to: List.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            return list
        }
    }
    
    /// Создание списка
    func createHandler(_ request: Request, data: ListData) throws -> Future<List> {
        let user = try request.requireAuthenticated(User.self)
        let list = try List(title: data.title, description: data.description, dateInsert: Date(), userID: user.requireID())
        
        return list.save(on: request)
    }
    
    /// Изменение списка
    func updateHandler(_ request: Request, data: ListData) throws -> Future<List> {
        return try request.parameters.next(List.self).flatMap(to: List.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            list.title = data.title
            list.description = data.description
            list.dateUpdate = Date()
            
            return list.save(on: request)
        }
    }
    
    /// Удаление списка
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(List.self).flatMap(to: HTTPStatus.self) { list in
            let user = try request.requireAuthenticated(User.self)
            guard list.userID == user.id else { throw Abort(.forbidden) }
            
            return try list.places.query(on: request).all().flatMap(to: HTTPStatus.self) { places in
                var deleted: [Future<Void>] = []
                for place in places {
                    let deletePlace = place.delete(on: request)
                    deleted.append(deletePlace)
                }
                
                let deleteList = list.delete(on: request)
                deleted.append(deleteList)
                
                return deleted.flatten(on: request).transform(to: .noContent)
            }
        }
    }
    
}
