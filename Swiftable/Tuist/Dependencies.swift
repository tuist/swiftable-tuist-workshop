import ProjectDescription

let dependencies = Dependencies(swiftPackageManager: .init([
    Package.package(url: "https://github.com/httpswift/swifter", .exact("1.5.0"))
]))
