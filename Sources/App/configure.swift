import Vapor
import Authentication
import FluentSQLite
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ environment: inout Environment, _ services: inout Services) throws {
    
    // Register providers first
    try services.register(FluentSQLiteProvider())
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
    
    // Configure a SQLite database
    let sqlite: SQLiteDatabase
    if environment.isRelease {
        sqlite = try SQLiteDatabase(storage: .file(path: "db.sqlite"))
    } else {
        sqlite = try SQLiteDatabase(storage: .memory)
    }
    
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    services.register(migrations)
    
    User.Public.defaultDatabase = .sqlite

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}
