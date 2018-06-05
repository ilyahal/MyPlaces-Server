import Vapor
import Authentication
import FluentMySQL
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ environment: inout Environment, _ services: inout Services) throws {
    
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    // Configure
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    // Configure a MySQL database
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "admin", password: "123456", database: "myplaces")
    let mysql = MySQLDatabase(config: mysqlConfig)
    
    // Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
    migrations.add(model: List.self, database: .mysql)
    migrations.add(model: Place.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: PlaceCategoryPivot.self, database: .mysql)
    services.register(migrations)
    
    User.Public.defaultDatabase = .mysql

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}
