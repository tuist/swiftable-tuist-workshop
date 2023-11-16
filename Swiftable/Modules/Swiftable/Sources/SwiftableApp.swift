import SwiftUI
import SwiftableKit
import Swifter

@main
struct SwiftableApp: App {
    let kit = SwiftableKit()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    let server = HttpServer()
                    server["/hello"] = { .ok(.htmlBody("You asked for \($0)"))  }
                    try? server.start()
                    print("Server running")
                })
        }
    }
}
