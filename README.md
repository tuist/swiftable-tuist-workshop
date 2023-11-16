# Swiftable Tuist Workshop

In this workshop, we will explore [Tuist](https://tuist.io) by creating a project and experimenting with various features.

The workshop is structured around a series of topics that are presented and should be followed sequentially. If, for any reason, you find yourself stuck in one of the topics, you will discover a commit SHA at the end of the topic that you can use to continue with the upcoming topics.

## Assert the successful completion of a topic

To assert the successful completion of a topic,
you can run the following command passing the topic number that you just completed

```bash
# Confirming the completion of step 1
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 1
```

## Requirements

- Xcode 15
- [Tuist](https://github.com/tuist/tuist#install-%EF%B8%8F) >= 3.33.0

## Topics

1. [What is Tuist?](#1-what-is-tuist)
2. [Project creation](#2-project-creation)
3. [Project edition](#3-project-edition)
4. [Project generation](#4-project-generation)
5. [Multi-target project](#5-multi-target-project)
6. [Multi-project workspace](#6-multi-project-workspace)
7. [Sharing code across projects](#7-sharing-code-across-projects)
8. [XcodeProj-native integration of Packages](#8-xcodeproj-native-integration-of-packages)
9. [Focused projects](#9-focused-projects)
10. [Focused and binary-optimized projects](#9-focused-and-binary-optimized-projects)
11. Incremental test execution

## 1. What is Tuist?

Tuist is a command-line tool that leverages Xcode Project generation to help teams overcome the challenges of scaling up development. Examples of challenges are:

- Git conflicts in Xcode projects.
- Inconsistencies across targets and projects.
- Unmaintainable target graph that creates strong dependencies with a platform team.
- Inefficient Xcode and clean builds.
- Suboptimal CI runs that lead to slow feedback loops.

### How does it work?

You describe your projects and workspaces in **Swift files (manifests)** using a Swift-based DSL.
We drew a lot of inspiration from the Swift Package Manager.
Unlike the Swift Package Manager, which is very focused on package management,
the APIs and models that you'll find in Tuist's DSL resemble Xcode projects and workspaces.

The following is an example of a typical Tuist project's structure:

```
Tuist/
    Config.swift
Project.swift
```

### Install Tuist

You can install Tuist by running the following command:

```bash
curl -Ls https://install.tuist.io | bash
```

## 2. Project creation

Tuist provides a command for creating projects,
`tuist init`,
but we are going to create the project manually to familiarize ourselves more deeply with the workflows and building blocks.

First of all, let's create a directory and call it `Swiftable`. Create it in this repository's directory:

```bash
mkdir -p Swiftable
cd Swiftable
```

Then we are going to create the following directories and files:

```bash
touch Project.swift
mkdir Tuist
echo 'import ProjectDescription
let config = Config()' > Tuist/Config.swift
```

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 2
```

If you get stuck, clone this repo and run `git checkout 2`.


## 3. Project edition

Tuist provides a `tuist edit` command that generates an Xcode project on the fly to edit the manifests.
The lifecycle of the project is tied to the lifecycle of the `tuist edit` command.
In other words, when the edit command finishes, the project is deleted.

Let's edit the project:

```
tuist edit
```

Then add the following content to the `Project.swift`:

```swift
import ProjectDescription

let project = Project(name: "Swiftable", targets: [
    Target(name: "Swiftable", platform: .iOS, product: .app, bundleId: "com.swiftable.App", sources: [
        "Sources/Swiftable/**/*.swift"
    ])
])
```

We are defining a project that contains an iOS app target that gets the sources from `Sources/Swiftable/**/*.swift`.
Then we need the app and the home view that the app will present when we launch it. For that, let's create the following files:

<details>
<summary>Sources/Swiftable/ContentView.swift</summary>

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
```
</details>

<details>
<summary>Sources/Swiftable/SwiftableApp.swift</summary>

```swift
import SwiftUI

@main
struct SwiftableApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
</details>

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 3
```

If you get stuck, clone this repo and run `git checkout 3`.

## 4. Project generation

Once we have the project defined, we can generate it with `tuist generate`.
The command generates an Xcode project and workspace and opens it automatically.
If you don't want to open it by default, you can pass the `--no-open` flag:

```bash
tuist generate
```

Try to run the app in the generated project.

Note that Tuist generated also a `Derived/` directory containing additional files.
In some scenarios, for example, when you define the content of the `Info.plist` in code or use other features of Tuist,
it's necessary to create files that the generated Xcode projects and workspaces can reference.
Those are automatically generated under the `Derived/` directory relative to the directory containing the `Project.swift`:

The next thing that we are going to do is including the Xcode artifacts and the `Derived` directory in the `.gitignore`:

```
*.xcodeproj
*.xcworkspace
Derived/
.DS_Store
```

Thanks to the above change, the chances of Git conflicts are minimized considerably.

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 4
```

If you get stuck, clone this repo and run `git checkout 4`.

## 5. Multi-target project

At some point in the lifetime of a project,
it becomes necessary to modularize a project into multiple targets.
For example to share source code across multiple targets.

Tuist supports that by abstracting away all the complexities that are associated with linking,
regardless of the complexity of your graph.

To see it in practice, we are going to create a new target called `SwiftableKit` that contains the logic for the app.
Then we are going to link the `Swiftable` target with the `SwiftableKit` target.

First, let's edit the `Project.swift` file:

```bash
tuist edit
```

And add the new target to the list:

```diff
import ProjectDescription

let project = Project(name: "Swiftable", targets: [
    Target(name: "Swiftable",
           platform: .iOS,
           product: .app,
           bundleId: "com.swiftable.App",
           sources: [
            "Sources/Swiftable/**/*.swift"
           ],
+           dependencies: [
+            .target(name: "SwiftableKit")
+           ]),
+    Target(name: "SwiftableKit",
+           platform: .iOS,
+           product: .framework,
+           bundleId: "com.swiftable.Kit",
+           sources: [
+            "Sources/SwiftableKit/**/*.swift"
+           ])
])
```

We can then create the following source file:

<details>
<summary>Sources/SwiftableKit/SwiftableKit.swift</summary>

```swift
import Foundation

public class SwiftableKit {
    public init() {}
    public func boludo() {}
}
```
</details>

And generate the project with `tuist generate`. Then import the framework from `Swiftable` and instantiate the above class to make sure the linking works successfully:

```diff
import SwiftUI
+import SwiftableKit

@main
struct SwiftableApp: App {
+    let kit = SwiftableKit()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Run the app and confirm that everything works as expected.
Note how Tuist added a build phase to the `Swiftable` to embed the dynamic framework automatically. This is necessary for the dynamic linker to link the framework at launch time.

<!-- Notes
- Change the platform to macOS and show how it validates the graph.
- Change the type to static library and show how the embed build phase is gone.
 -->

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 5
```

If you get stuck, clone this repo and run `git checkout 5`.

## 6. Multi-project workspace

Even though with Xcode projects and workspaces gitignored, there's less need for Xcode workspaces.
You might want to treat projects as an umbrella to group multiple targets that belong to the same domain and use workspaces to group all the projects.

Tuist supports that too.
To see it in practice, we are going to move the `Project.swift` under `Sources/Swiftable`:

```bash
mv Sources Modules

mkdir -p Modules/Swiftable/Sources
mv Modules/Swiftable/ContentView.swift Modules/Swiftable/Sources/ContentView.swift
mv Modules/Swiftable/SwiftableApp.swift Modules/Swiftable/Sources/SwiftableApp.swift

mkdir -p Modules/SwiftableKit/Sources
mv Modules/SwiftableKit/SwiftableKit.swift Modules/SwiftableKit/Sources/SwiftableKit.swift

touch Workspace.swift

cp Project.swift Modules/Swiftable/Project.swift
mv Project.swift Modules/SwiftableKit/Project.swift
```

We'll end up with the following directory structure:

```bash

├── Modules
│   ├── Swiftable
│   │   ├── Project.swift
│   │   └── Sources
│   │       ├── ContentView.swift
│   │       └── SwiftableApp.swift
│   └── SwiftableKit
│       ├── Project.swift
│       └── Sources
│           └── SwiftableKit.swift
├── Tuist
│   └── Config.swift
└── Workspace.swift
```

Note how we've organized the project in multiple modules, each of which has its own `Project.swift`. Now let's edit it with `tuist edit` and make sure we have the following content in the files:


<details>
<summary>Workspace.swift</summary>

```swift
import ProjectDescription

let workspace = Workspace(name: "Swiftable", projects: ["Modules/*"])
```
</details>

<details>
<summary>Modules/Swiftable/Project.swift</summary>

```swift
import ProjectDescription

let project = Project(name: "Swiftable", targets: [
    Target(name: "Swiftable",
           platform: .iOS,
           product: .app,
           bundleId: "com.swiftable.App",
           sources: [
            "./Sources/**/*.swift"
           ],
           dependencies: [
            .project(target: "SwiftableKit", path: "../SwiftableKit")
           ])
])
```
</details>

<details>
<summary>Modules/SwiftableKit/Project.swift</summary>

```swift
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
```
</details>

Generate the project and makes sure it compiles and runs successfully.

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 6
```

If you get stuck, clone this repo and run `git checkout 6`.

## 7. Sharing code across projects

When you start splitting your project into multiple `Project.swift` a natural need for sharing code to ensure consistency arises.
Luckily, Tuist provides an answer for that, and it's called **Project Description Helpers**.
Let's create a folder `Tuist/ProjectDescriptionHelpers` and a file `Project+Swiftable.swift`:

```bash
mkdir -p Tuist/ProjectDescriptionHelpers
touch Tuist/ProjectDescriptionHelpers/Project+Swiftable.swift
```

Then let's edit the Tuist project with `tuist edit` and edit the following files:


<details>
<summary>Tuist/ProjectDescriptionHelpers/Project+Swiftable.swift</summary>

```swift
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
```
</details>

<details>
<summary>Modules/Swiftable/Project.swift</summary>

```swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.swiftable(module: .app)
```
</details>

<details>
<summary>Modules/SwiftableKit/Project.swift</summary>

```swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.swiftable(module: .kit)
```
</details>

<!-- Notes
- Talk about how there's total flexibility about what can be added in the ProjectDescriptionsHelper module
- Mention that they can use their own abstractions to codify conventions.
-->

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 7
```

If you get stuck, clone this repo and run `git checkout 7`.

## 8. XcodeProj-native integration of Packages

Tuist supports integrating Swift Packages into your projects using Xcode's standard integration.
However, that integration is not ideal at scale for a few reasons:

- Clean builds, which happen in CI environments and often locally when developers clean their environments to resolve cryptic Xcode errors, lead to the resolution and compilation of those packages, which slows the builds.
- There's little configurability of the integration, which creates a strong dependency on Apple to fix the issues that arise via their radar system.
- There's little room for optimization. For example to turn them into binaries and speed up clean builds.

Because of that, Tuist proposes a different integration method, which **takes the best of SPM and CocoaPods worlds.**
It uses SPM to resolve the packages, and CocoaPods' idea of integrating dependencies using XcodeProj primitives such as targets and build settings. Let's see how it works in action.

Create the following following file:

```bash
touch Tuist/Dependencies.swift
```

And use `tuist edit` to edit it with Xcode. We'll edit the following files:

<details>
<summary>Tuist/Dependencies.swift</summary>

```swift
import ProjectDescription

let dependencies = Dependencies(swiftPackageManager: .init([
    Package.package(url: "https://github.com/httpswift/swifter", .exact("1.5.0"))
]))
```
</details>

<details>
<summary>Tuist/ProjectDescriptionHelpers/Project+Swiftable.swift</summary>

```diff
import ProjectDescription

+public enum Dependency {
+    case module(Module)
+    case package(String)
+    
+    var targetDependency: TargetDependency {
+        switch self {
+        case let .module(module): TargetDependency.project(target: module.name, path: "../\(module.name)")
+        case let .package(package): TargetDependency.external(name: package)
+        }
+    }
+}

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
    
+    var dependencies: [Dependency] {
+        switch self {
+        case .app: [.module(.kit)]
+        case .kit: [.package("Swifter")]
+        }
+    }
}

public extension Project {
    static func swiftable(module: Module) -> Project {
+        let dependencies = module.dependencies.map(\.targetDependency)
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

```
</details>

Note that we add a new `enum`, `Dependency` that we can use to model dependencies, which can now be of two types, `module` or `package`. The enum exposes a `targetDependency` property to return the value that targets need when defining their dependencies.

Now we need to run `tuist fetch`, which uses the Swift Package Manager to resolve the dependencies.
After they've been fetched, you can run `tuist generate` to generate the project and open it.

Then let's edit the `SwiftableApp.swift` to run the server when the view appears:

```diff
import SwiftUI
import SwiftableKit
+import Swifter

@main
struct SwiftableApp: App {
    let kit = SwiftableKit()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
+                .onAppear(perform: {
+                    let server = HttpServer()
+                    server["/hello"] = { .ok(.htmlBody("You asked for \($0)"))  }
+                    try? server.start()
+                    print("Server running")
+                })
        }
    }
}
```

Before we wrap up this topic, add `Tuist/Dependencies` to the `.gitignore`.

<!-- Notes
- Talk about how dependencies are integrated as Xcode projects
- Talk about how they can use the API in Dependencies.swift to override build settings and products.
-->

### Before continuing ⚠️

```bash
bash <(curl -sSL https://raw.githubusercontent.com/tuist/swiftable-tuist-workshop/main/test.sh) 8
```

If you get stuck, clone this repo and run `git checkout 8`.

## 9. Focused projects

When modular projects grow, it's common to face Xcode and compilation slowness.
It's normal, your project is large, and Xcode has a lot to index and process.
If you think about it, it doesn't make sense to load an entire graph of targets,
when you plan to only **focus** on a few of them.

Tuist provides an answer to that, and it's built into the command that you've been using since the beginning, `tuist generate`.

If you pass a list of targets that you plan to focus on, Tuist will generate projects with only the targets that you need to work on that one. For example, let's say we'd like to focus on `SwiftableKit`, for which we don't need `Swiftable`. We can then run:

```
tuist generate SwiftableKit
```

You'll notice that `Swiftable` will magically ✨ disappear from the generated project. If you want to include it too, you can pass it in the list of arguments:

```
tuist generate Swiftable SwiftableKit
```

Tuist gives developers an interface to **express their target of focus**.

## 9. Focused and binary-optimized projects