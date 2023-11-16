import ProjectDescription

let project = Project(name: "Swiftable", targets: [
    Target(name: "Swiftable",
           platform: .iOS,
           product: .app,
           bundleId: "com.swiftable.App",
           sources: [
            "Sources/Swiftable/**/*.swift"
           ],
           dependencies: [
            .target(name: "SwiftableKit")
           ]),
    Target(name: "SwiftableKit",
           platform: .iOS,
           product: .staticLibrary,
           bundleId: "com.swiftable.Kit",
           sources: [
            "Sources/SwiftableKit/**/*.swift"
           ])
])
