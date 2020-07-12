// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Valog",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Valog", targets: ["Valog"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.14.0"),
//        .package(url: "https://github.com/vapor/redis", from: "4.0.0-beta.3"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
//        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0-rc"),
        // CryptoSwift
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.3.0")),
        // Yams, Yaml 解析器
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        // SMTP Service from IBM
        .package(url: "https://github.com/Harley-xk/Swift-SMTP", .upToNextMinor(from: "5.1.0")),
        // 自带的 HttpClient 不好用，上神器
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0"))
    ],
    targets: [
        .target(name: "App",
                dependencies: [
                    "Fluent",
                    "FluentPostgresDriver",
//                    "FluentMySQLDriver",
//                    "Redis",
                    "CryptoSwift",
                    "Vapor",
                    "Yams",
                    "SwiftSMTP",
                    "Alamofire"
            ]
        ),
        .target(name: "Valog", dependencies: ["App"]),
    ]
)

