import SwiftUI
import LogBook

public struct LogsView: View {
    @Environment(\.logBook) var logBook
    @State var logs: [Log] = []
    @Environment(\.presentationMode) var presentationMode

    @State var alertMessage: String = ""
    @State var isAlertShown = false

    @State var shareContinuation: () -> Void = { }
    @State var shareURL: URL?

    public init() { }

    static let display = SwiftUIDisplay()
    var isSharePresented: Binding<Bool> {
        Binding {
            shareURL != nil
        } set: { newValue in
            shareURL = newValue ? shareURL : nil
        }
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(logs, id: \.createdAt) { log in
                    Self.display.display(log: log)
                    #if os(iOS)
                        .background(Color(UIColor.systemBackground))
                    #elseif os(macOS)
                        .background(Color(NSColor.windowBackgroundColor))
                    #endif
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        #if os(iOS)
        .background(Color.secondary.opacity(0.15).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: isSharePresented) {
            ShareSheet(activityItems: [shareURL!]) {
                isSharePresented.wrappedValue = false
            }
        }
        #endif
        .alert(isPresented: $isAlertShown, content: {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Okay")))
        })
        .onAppear {
            Task { logs = await logBook.logs() }
        }
        .id(ObjectIdentifier(logBook))
        .navigationTitle("Logs")
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.primary)
                        .opacity(0.5)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await shareLogs() }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        #endif
    }

    #if os(iOS)
    private func shareLogs() async {
        do {
            shareURL = try await logBook.withExportedLogFile()
        } catch {
            alertMessage = error.localizedDescription
            isAlertShown = true
        }
    }
    #endif
}
