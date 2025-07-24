// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ADHDFocusApp",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.0"),
        .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "ADHDFocusApp",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
) 