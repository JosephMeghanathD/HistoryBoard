import SwiftUI

struct ContentView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    var onPaste: () -> Void // Callback to close window
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Clipboard History")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(clipboardManager.history, id: \.self) { item in
                        Button(action: {
                            selectItem(item)
                        }) {
                            Text(item)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .background(VisualEffectView(material: .windowBackground, blendingMode: .behindWindow))
        .cornerRadius(10)
    }
    
    func selectItem(_ item: String) {
            // 1. Put item back on clipboard
            clipboardManager.copyToPasteboard(text: item)
            
            // 2. Hide the whole app (Immediately returns focus to the previous app)
            NSApp.hide(nil)
            onPaste() // Updates internal state
            
            // 3. Wait a tiny bit for the system to switch focus, then paste
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                clipboardManager.pasteToActiveApp()
            }
        }
}

// Helper for blurry background
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
