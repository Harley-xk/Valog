//import Fluent
//import FluentSQLiteDriver
import Vapor
import FluentMySQLDriver
import Redis

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    try app.beforeConfigure()
    
    let path = Path(app.directory.workingDirectory + "config-" + app.environment.name + ".json")
    let config = try Config.decode(from: path)

    app.server.configuration.hostname = config.server.host
    app.server.configuration.port = config.server.port

    app.redis.configuration = RedisKit.RedisConfiguration(
        hostname: config.redis.host,
        port: config.redis.port,
        password: config.redis.password
    )
    
    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure MySQL database
    app.databases.use(.mysql(
        hostname: config.database.host,
        port: config.database.port,
        username: config.database.username,
        password: config.database.password,
        database: config.database.name,
        tlsConfiguration: .none
    ), as: .mysql)

    // Configure migrations
    try prepareMigrations(app)
    
    // Configure routes
    try routes(app)
}

struct Config: Codable {
    
    struct Server: Codable {
        var host: String
        var port: Int
    }
    
    struct Database: Codable {
        var name: String
        var host: String
        var port: Int
        var username: String
        var password: String
    }
    
    struct Redis: Codable {
        var host: String
        var port: Int
        var password: String?
    }
    
    var server: Server
    var database: Database
    var redis: Redis
}
