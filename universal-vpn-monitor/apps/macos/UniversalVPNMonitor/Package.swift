// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UniversalVPNMonitor",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "UniversalVPNMonitor", targets: ["UniversalVPNMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "UniversalVPNMonitor",
            path: "Sources"
        )
    ]
)
