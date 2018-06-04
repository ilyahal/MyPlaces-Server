// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MyPlaces",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.3"),

        // 🖋🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2.2"),

        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf", from: "3.0.0-rc.2.2"),

        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth", from: "2.0.0-rc.4.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
