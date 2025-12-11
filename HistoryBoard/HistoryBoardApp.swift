import SwiftUI

@main
struct HistoryBoardApp: App {
    // Connects the logic to the macOS system lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// This class handles the app startup and window management
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: HistoryWindow!
    var clipboardManager = ClipboardManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Setup the User Interface
        let contentView = ContentView(clipboardManager: clipboardManager) {
            self.window.orderOut(nil)
        }
        
        // 2. Create the floating window immediately (but keep it hidden)
        window = HistoryWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: contentView)
        
        // 3. Connect the Hotkey to the Window
        // This was the missing piece! We connect it right at startup.
        clipboardManager.onToggle = { [weak self] in
            self?.toggleWindow()
        }
    }
    
    func toggleWindow() {
        if window.isVisible {
            print("🙈 Hiding Window")
            window.orderOut(nil)
        } else {
            print("👀 Showing Window")
            // Center window on screen
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                let newX = screenRect.midX - (window.frame.width / 2)
                let newY = screenRect.midY - (window.frame.height / 2)
                window.setFrameOrigin(NSPoint(x: newX, y: newY))
            }
            
            // Force focus to our app so we can click things
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }
}
