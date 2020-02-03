//import Fluent
//import FluentSQLiteDriver
import Vapor
import Leaf

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    try app.beforeConfigure()

    // Leaf Template Renderer
    app.views.use(.leaf)
    
    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure SQLite database
//    app.databases.use(.sqlite(.file(app.directory.dataDirectory + "Data.sqlite")), as: .sqlite)

    // Configure migrations
//    try prepareMigrations(app)
    
    // Configure routes
    try routes(app)
}
