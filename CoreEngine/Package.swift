// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreEngine",
    platforms: [
        .iOS(.v16), // Set minimum platform to iOS 13
//        .visionOS(.v1)
        // include other platforms if needed
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreEngine",
            targets: ["CoreEngine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on. github.com/firebase/firebase-ios-sdk.git
        .package(url: "https://github.com/realm/realm-cocoa.git", from: "20.0.0"),
        // Firebase 11.x required for App Store upload (ITMS-91061): only 11.x pulls
        // privacy-manifest-bearing transitive SDKs — GoogleUtilities >= 7.13,
        // gtm-session-fetcher >= 3.4, promises >= 2.4. The 10.x line pins
        // GoogleUtilities < 7.13 (no manifest), so a 10.x floor can't fix it.
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "CoreEngine",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-cocoa"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
//                .product(name: "Firebase", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "CoreEngineTests",
            dependencies: ["CoreEngine"]),
    ]
)
