// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SmartDashboardClient",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SmartDashboardClient",
            path: "Sources"
        ),
    ]
)
