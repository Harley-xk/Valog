// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Valog",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta.2"),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
//        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-alpha.1"),
        // 🗺 A Swift DSL for type-safe, extensible, and transformable HTML documents.
        .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.3.0"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0-beta"),
        // CryptoSwift
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Fluent", "FluentMySQLDriver", "Html", "CryptoSwift", "Vapor"]),
//        .target(name: "App", dependencies: ["Leaf", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
    ]
)

