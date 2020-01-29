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
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-alpha.1"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-beta.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Fluent", "FluentSQLiteDriver", "Leaf", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "XCTVapor"])
    ]
)

