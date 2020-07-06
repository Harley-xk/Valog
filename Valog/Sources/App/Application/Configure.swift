//import Fluent
//import FluentSQLiteDriver
import Vapor
import FluentPostgresDriver
//import FluentMySQLDriver
//import Redis

// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // initialize
    let config = try app.prepareConfigure()
    
    app.http.server.configuration.hostname = config.server.host
    app.http.server.configuration.port = config.server.port

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
//        port: config.database.port ?? 3306,
//        username: config.database.username,
//        password: config.database.password,
//        database: config.database.name,
//        tlsConfiguration: .none
//    ), as: .mysql)

    // Configure migrations
    try prepareMigrations(app)
    
    // Configure routes
    try routes(app)
    
    // 设置时间 JSON 格式
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    decoder.dateDecodingStrategy = .secondsSince1970
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
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
        var projectPath: String
    }
    
    struct Webhook: Codable {
        var token: String
    }
    
    /// SMTP 发件箱配置
    struct SMTP: Codable {
        var host: String
        var senderName: String
        var senderAccount: String
        var password: String
    }
    
    var server: Server
    var database: Database
    var redis: Redis
    var webSite: WebSite
    var hook: Webhook
    var smtp: SMTP
}
