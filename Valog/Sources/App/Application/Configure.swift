//import Fluent
//import FluentSQLiteDriver
import Vapor
import Leaf
import FluentMySQLDriver

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    try app.beforeConfigure()

    // Leaf Template Renderer
    app.views.use(.leaf)
    
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
