import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    var databases = DatabasesConfig()
    let mysqlConfig = MySQLDatabaseConfig(hostname: "119.29.66.191", port: 3306, username: "pubgnewsbox", password: "0054321", database: "pubg_news_box")
    let database = MySQLDatabase(config: mysqlConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    //let mysqlConfig = MySQLDatabaseConfig(hostname: "119.29.66.191", port: 3306, username: "pubgnewsbox", password: "0054321", database: "pubg_news_box")
    //services.register(mysqlConfig)
    
    
    /// Configure migrations
    var migrations = MigrationConfig()
    /*-------------------------------*/
    
    migrations.add(model: UserRegistInfo.self, database: .mysql)
    migrations.add(model: SercretKey.self, database: .mysql)
    migrations.add(model: UserInfo.self, database: .mysql)
    /*-------------------------------*/
    services.register(migrations)

}
