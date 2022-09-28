import SwiftUI

struct CollapsibleModifier: ViewModifier {
    let title: String

    @State var isCollapsed = true

    @ViewBuilder
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Button(title) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isCollapsed.toggle()
                }
            }
            .buttonStyle(CollapsibleButtonStyle(isCollapsed: isCollapsed))

            if !isCollapsed {
                Divider()
                content
            }
        }
    }
}

extension View {
    func collapsible(title: String) -> some View {
        modifier(CollapsibleModifier(title: title))
    }
}

struct CollapsibleButtonStyle: ButtonStyle {
    let isCollapsed: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(isCollapsed ? .zero : .degrees(90))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .foregroundColor(.accentColor)
#if os(iOS)
        .background(Color(UIColor.systemBackground))
#elseif os(macOS)
        .background(Color(NSColor.windowBackgroundColor))
#endif
        .animation(.easeOut(duration: 0.2), value: isCollapsed)
        .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
