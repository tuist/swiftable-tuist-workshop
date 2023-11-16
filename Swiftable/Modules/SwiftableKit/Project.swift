import ProjectDescription

let project = Project(name: "SwiftableKit", targets: [
    Target(name: "SwiftableKit",
           platform: .iOS,
           product: .staticLibrary,
           bundleId: "com.swiftable.Kit",
           sources: [
            "./Sources/**/*.swift"
           ])
])
