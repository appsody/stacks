// swift-tools-version:5.1
import PackageDescription

/**
 * This source file is supplied by the appsody/kitura base image. DO NOT MODIFY.
 */

let package = Package(
    name: "AppsodyKitura",
    products: [
        .library(
            name: "AppsodyKitura",
            targets: ["AppsodyKitura"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.9.0")),
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0"),
      .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.0"),
      .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.0.0"),
      .package(url: "https://github.com/IBM-Swift/Health.git", from: "1.0.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.3.0"),
    ],
    targets: [
      .target(name: "AppsodyKitura", dependencies: [ "Kitura", "HeliumLogger", "Configuration", "SwiftMetrics", "Health", "KituraOpenAPI" ]),
      .testTarget(name: "AppsodyKituraTests" , dependencies: [.target(name: "AppsodyKitura"), "Kitura", "HeliumLogger" ])
    ]
)
