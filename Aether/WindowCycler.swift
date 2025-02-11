//
//  WindowCycler.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import Cocoa

class WindowCycler {
    private var windows: [AXUIElement] = []
    private var currentIndex: Int = -1
    private let app: NSRunningApplication
    private let windowBehavior: WindowBehavior

    init(app: NSRunningApplication, windowBehavior: WindowBehavior) {
        self.app = app
        self.windowBehavior = windowBehavior
        updateWindows()
        print("WindowCycler: Initialized for app \(app.localizedName ?? "unknown")")
    }
    
    func updateWindows() {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
        if result == .success, let windowArray = value as? [AXUIElement] {
            if !windowArray.isEmpty {
                windows = windowArray.filter { window in
                    var minimizedValue: CFTypeRef?
                    if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedValue) == .success,
                       let isMinimized = minimizedValue as? Bool {
                        return !isMinimized
                    }
                    return true
                }
            } else {
                windows = []
            }
        } else {
            // Fallback: try to get the main window.
            var mainValue: CFTypeRef?
            let mainResult = AXUIElementCopyAttributeValue(appElement, kAXMainWindowAttribute as CFString, &mainValue)
            if mainResult == .success, let mainValue = mainValue {
                windows = [mainValue as! AXUIElement]
            } else {
                windows = []
            }
        }
        print("WindowCycler: Found \(windows.count) window(s) for app \(app.localizedName ?? "unknown")")
    }
    
    func cycleToNextWindow() {
        print("WindowCycler: Starting window cycle")
        updateWindows()
        
        // Force the app to become active
        app.activate(options: [.activateAllWindows])
        
        if windows.isEmpty {
            print("WindowCycler: No windows found. Retrying after delay.")
            // Allow a short delay for the app to create windows.
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.updateWindows()
                if self.windows.isEmpty {
                    print("WindowCycler: Still no windows found after delay. Activating app.")
                    self.app.activate(options: [.activateAllWindows])
                } else {
                    self.currentIndex = 0
                    self.raiseWindow(self.windows[self.currentIndex])
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            return
        }
        
        currentIndex = (currentIndex + 1) % windows.count
        let nextWindow = windows[currentIndex]
        
        print("WindowCycler: Cycling to window \(currentIndex + 1) of \(windows.count)")
        
        // A short delay gives the system time to fully activate the app.
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.raiseWindow(nextWindow)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    private func raiseWindow(_ window: AXUIElement) {
        let error = AXUIElementPerformAction(window, kAXRaiseAction as CFString)
        if error != .success {
            print("WindowCycler: Failed to raise window (error \(error.rawValue)). Activating app instead.")
            app.activate(options: [.activateAllWindows])
        } else {
            print("WindowCycler: Raised window \(currentIndex + 1) of \(windows.count).")
        }
    }
}
