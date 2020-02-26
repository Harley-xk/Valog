//import Fluent
//import FluentSQLiteDriver
import Vapor
import FluentPostgresDriver
//import Redis

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    let config = try app.prepareConfigure()
    
    app.server.configuration.hostname = config.server.host
    app.server.configuration.port = config.server.port

//    app.redis.configuration = RedisKit.RedisConfiguration(
//        hostname: config.redis.host,
//        port: config.redis.port,
//        password: config.redis.password
//    )
    
    // Serves files from `Public/` directory
//    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(
        hostname: config.database.host,
        username: config.database.username,
        password: config.database.password,
        database: config.database.name
        ), as: .psql)
    
    // Configure MySQL database
//    app.databases.use(.mysql(
//        hostname: config.database.host,
//        port: config.database.port,
//        username: config.database.username,
//        password: config.database.password,
//        database: config.database.name,
//        tlsConfiguration: .none
//    ), as: .mysql)

    // Configure migrations
    try prepareMigrations(app)
    
    // Configure routes
    try routes(app)
    
    // clone posts if not exists
    if !Path(app.directory.storageDirectory + "Posts").exists {
        try SimpleShell.runSynchronously(
            cmd: "git clone https://github.com/Harley-xk/Posts.git",
            on: app.directory.storageDirectory
        )
    }
    
    let request = Request(application: app, on: app.eventLoopGroup.next())

    // 更新数据库
    _ = try PostController().reloadPosts(request)
}

struct Config: Codable {
    
    struct Server: Codable {
        var host: String
        var port: Int
    }
    
    struct Database: Codable {
        var name: String
        var host: String
        var port: Int?
        var username: String
        var password: String
    }
    
    struct Redis: Codable {
        var host: String
        var port: Int
        var password: String?
    }
    
    struct WebSite: Codable {
        var root: String
    }
    
    var server: Server
    var database: Database
    var redis: Redis
    var webSite: WebSite
}
