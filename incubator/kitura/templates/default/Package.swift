// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "server",
    dependencies: [
      .package(path: ".appsody/AppsodyKitura"),
    ],
    targets: [
      .target(name: "server", dependencies: [ .target(name: "Application") ]),
      .target(name: "Application", dependencies: [ "AppsodyKitura" ]),
      .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "AppsodyKitura" ])
    ]
)
