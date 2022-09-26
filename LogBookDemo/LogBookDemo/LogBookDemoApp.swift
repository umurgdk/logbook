import SwiftUI
import LogBook
import LogBookUI

@main
struct LogBookDemoApp: App {
    let logBook = LogBook(persistance: InMemoryPersistance())
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.logger, logBook.makeLogger("Root", in: "DemoApp"))
                .environment(\.logBook, logBook)
        }
    }
}
