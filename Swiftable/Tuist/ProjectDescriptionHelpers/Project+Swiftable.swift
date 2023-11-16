import ProjectDescription

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
    
    var dependencies: [Module] {
        switch self {
        case .app: [.kit]
        case .kit: []
        }
    }
}

public extension Project {
    static func swiftable(module: Module) -> Project {
        let dependencies = module.dependencies.map({ TargetDependency.project(target: $0.name, path: "../\($0.name)") })
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
