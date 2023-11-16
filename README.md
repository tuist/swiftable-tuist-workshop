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
4. Multi-project workspace
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