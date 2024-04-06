// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreEngine",
    platforms: [
        .iOS(.v15), // Set minimum platform to iOS 13
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
        .package(url: "https://github.com/realm/realm-cocoa.git", branch: "master"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.18.0")
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
