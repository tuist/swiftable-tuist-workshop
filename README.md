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
4. [Multi-project workspace](#5-multi-project-workspace)
5. Declaring dependencies
6. The project graph
7. Focused projects
8. Caching
9. Incremental test execution

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