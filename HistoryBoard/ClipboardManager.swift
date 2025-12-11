import SwiftUI
import AppKit

class ClipboardManager: ObservableObject {
    @Published var history: [String] = []
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    
    init() {
        changeCount = pasteboard.changeCount
        // Check for changes every 0.5 seconds
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
    }
    
    func checkForChanges() {
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            if let str = pasteboard.string(forType: .string) {
                // Avoid duplicates at the top
                if history.first != str {
                    DispatchQueue.main.async {
                        self.history.insert(str, at: 0)
                        // Keep only last 50 items
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
        // This requires Accessibility permissions!
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Command down
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        cmdDown?.flags = .maskCommand
        
        // V down
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        vDown?.flags = .maskCommand
        
        // V up
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        vUp?.flags = .maskCommand
        
        // Command up
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        
        // Post events
        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}