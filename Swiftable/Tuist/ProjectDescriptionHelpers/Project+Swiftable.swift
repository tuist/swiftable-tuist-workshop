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

public enum Module {
    case app
    case kit
    case feature(String)
    
    var rawValue: String {
        switch self {
        case .app: "app"
        case .kit: "kit"
        case .feature(let feature): feature
        }
    }
        
    var product: Product {
        switch self {
        case .app:
            return .app
        case .kit:
            return .staticLibrary
        case .feature:
            return .staticLibrary
        }
    }
    
    var name: String {
        switch self  {
        case .app: "Swiftable"
        case let .feature(name): name.capitalized
        default: "Swiftable\(rawValue.capitalized)"
        }
    }
    
    var dependencies: [Dependency] {
        switch self {
        case .app: [.module(.kit)]
        case .kit: [.package("Swifter")]
        case .feature: [.module(.kit)]
        }
    }
    
    var resources: ProjectDescription.ResourceFileElements? {
        switch self {
        case .kit: return ["Resources/**/*"]
        case .app: return nil
        case .feature: return nil
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
                   resources: module.resources,
                   dependencies: dependencies)
        ])
    }
}
