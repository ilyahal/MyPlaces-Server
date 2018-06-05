import Vapor

/// Creates an instance of Application. This is called from main.swift in the run target.
public func app(_ environment: Environment) throws -> Application {
    var config = Config.default()
    var environment = environment
    var services = Services.default()
    try configure(&config, &environment, &services)
    
    let app = try Application(config: config, environment: environment, services: services)
    try boot(app)
    
    return app
}
