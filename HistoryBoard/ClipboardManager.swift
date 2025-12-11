import SwiftUI
import AppKit
import HotKey // Make sure this is imported!
internal import Combine

class ClipboardManager: ObservableObject {
    @Published var history: [String] = []
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    
    // We store the hotkey here to keep it alive
    private var hotKey: HotKey?
    
    // Callback to tell the main app to show the window
    var onToggle: (() -> Void)?
    
    init() {
        changeCount = pasteboard.changeCount
        
        // 1. Setup the HotKey (Command + Shift + V)
        self.hotKey = HotKey(key: .v, modifiers: [.command, .shift])
        
        // 2. Define what happens when pressed
        self.hotKey?.keyDownHandler = { [weak self] in
            print("🔥 Hotkey Pressed!") // Look for this in the console
            DispatchQueue.main.async {
                self?.onToggle?()
            }
        }
        
        // 3. Start the timer to watch for copies
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
    }
    
    func checkForChanges() {
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            if let str = pasteboard.string(forType: .string) {
                if history.first != str {
                    DispatchQueue.main.async {
                        print("📋 New item copied: \(str.prefix(20))...")
                        self.history.insert(str, at: 0)
                        if self.history.count > 50 { self.history.removeLast() }
                    }
                }
            }
        }
    }
    
    func copyToPasteboard(text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func pasteToActiveApp() {
        print("⌨️ Attempting to paste...")
        let source = CGEventSource(stateID: .hidSystemState)
        
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        cmdDown?.flags = .maskCommand
        
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        vDown?.flags = .maskCommand
        
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        vUp?.flags = .maskCommand
        
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        
        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}
