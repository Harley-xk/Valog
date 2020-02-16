//import Fluent
//import FluentSQLiteDriver
import Vapor
import FluentMySQLDriver
import Redis

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    try app.beforeConfigure()
    
    app.redis.configuration = .init()
    
    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure MySQL database
    app.databases.use(.mysql(
        hostname: "localhost",
        port: 8889,
        username: "root",
        password: "root",
        database: "Valog",
        tlsConfiguration: .none
    ), as: .mysql)

    // Configure migrations
    try prepareMigrations(app)
    
    // Configure routes
    try routes(app)
}
