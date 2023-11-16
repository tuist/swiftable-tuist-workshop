import ProjectDescription

public enum Dependency {
    case module(Module)
    case package(String)
    
    var targetDependency: TargetDependency {
        switch self {
        case let .module(module): TargetDependency.project(target: module.name, path: "../\(module.name)")
        case let .package(package): TargetDependency.external(name: package)
        }
    }
}

public enum Module: String {
    case app
    case kit
    
    var product: Product {
        switch self {
        case .app:
            return .app
        case .kit:
            return .framework
        }
    }
    
    var name: String {
        switch self  {
        case .app: "Swiftable"
        default: "Swiftable\(rawValue.capitalized)"
        }
    }
    
    var dependencies: [Dependency] {
        switch self {
        case .app: [.module(.kit)]
        case .kit: [.package("Swifter")]
        }
    }
}

public extension Project {
    static func swiftable(module: Module) -> Project {
        let dependencies = module.dependencies.map(\.targetDependency)
        return Project(name: module.name, targets: [
            Target(name: module.name,
                   platform: .iOS,
                   product: module.product,
                   bundleId: "com.swiftable.\(module.name)",
                   sources: [
                    "./Sources/**/*.swift"
                   ],
                   dependencies: dependencies)
        ])
    }
}
