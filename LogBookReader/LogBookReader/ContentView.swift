import SwiftUI
import UniformTypeIdentifiers
import LogBook
import LogBookUI

struct ContentView: View {
    @State var logBook = LogBook(persistance: InMemoryPersistance())
    var body: some View {
        LogsView()
            .environment(\.logBook, logBook)
            .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
                _ = providers.first?.loadObject(ofClass: URL.self, completionHandler: { url, error in
                    guard let url = url else { return }

                    do {
                        let logs = try readLogs(from: url)
                        DispatchQueue.main.async {
                            let _logs = logs
                            setLogs(logs)
                        }
                    } catch let error as DecodingError {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = error.localizedDescription
                            _ = alert.runModal()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            _ = NSAlert(error: error).runModal()
                        }
                    }
                })

                return true
            }
    }

    func setLogs(_ logs: [Log]) {
        logBook = LogBook(logs: logs)
    }
}

func readLogs(from url: URL) throws -> [Log] {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([Log].self, from: data)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
