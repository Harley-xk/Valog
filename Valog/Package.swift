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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
//        .package(url: "https://github.com/vapor/redis", from: "4.0.0-beta.3"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
//        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0-rc"),
        // CryptoSwift
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.0.0")),
        // Yams, Yaml 解析器
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
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
            ]
        ),
        .target(name: "Valog", dependencies: ["App"]),
    ]
)

