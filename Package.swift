// swift-tools-version:5.5

import PackageDescription

let package = Package(
        name: "ActionSheet",
        platforms: [
            .iOS(.v13),
        ],
        products: [
            .library(
                    name: "ActionSheet",
                    targets: ["ActionSheet"]
            ),
        ],
        dependencies: [
            .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.1")),
            .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
            .package(url: "https://github.com/horizontalsystems/UIExtensions.Swift.git", .upToNextMajor(from: "1.0.0")),
        ],
        targets: [
            .target(
                    name: "ActionSheet",
                    dependencies: [
                        "RxSwift",
                        .product(name: "RxCocoa", package: "RxSwift"),
                        "SnapKit",
                        .product(name: "UIExtensions", package: "UIExtensions.Swift"),
                    ]
            ),
        ]
)
