import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
    description: "Creates a new feature module",
    attributes: [
        nameAttribute,
    ],
    items: [
        .file(path: "Modules/\(nameAttribute)/Project.swift",
              templatePath: "Feature/Project.stencil"),
        .file(path: "Modules/\(nameAttribute)/Sources/Feature.swift",
              templatePath: "Feature/Sources/Feature.stencil")
    ]
)
