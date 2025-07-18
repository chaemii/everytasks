// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ADHDFocusApp",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.0")
    ],
    targets: [
        .target(
            name: "ADHDFocusApp",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ]
        )
    ]
) 