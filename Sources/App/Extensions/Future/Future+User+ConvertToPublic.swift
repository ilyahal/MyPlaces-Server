import Vapor

extension Future where T: User {
    
    /// Преобразовать в публичную версию
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
    
}
