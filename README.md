# Swiftable Tuist Workshop

In this workshop, we will explore [Tuist](https://tuist.io) by creating a project and experimenting with various features.

The workshop is structured around a series of topics that are presented and should be followed sequentially. If, for any reason, you find yourself stuck in one of the topics, you will discover a commit SHA at the end of the topic that you can use to continue with the upcoming topics.

## Requirements

- Xcode 15
- [Tuist](https://github.com/tuist/tuist#install-%EF%B8%8F) >= 3.33.0

## Topics

1. [What is Tuist?](#1-what-is-tuist)
2. Project creation
3. Multi-project workspace
4. Declaring dependencies
5. The project graph
6. Focused projects
7. Caching
7. Incremental test execution

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