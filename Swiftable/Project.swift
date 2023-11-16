import ProjectDescription

let project = Project(name: "Swiftable", targets: [
    Target(name: "Swiftable", platform: .iOS, product: .app, bundleId: "com.swiftable.App", sources: [
        "Sources/Swiftable/**/*.swift"
    ])
])
