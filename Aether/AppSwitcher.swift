//
//  AppSwitcher.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import AppKit
import CoreGraphics

class AppSwitcher {
    // Keep a window cycler for each app (keyed by process identifier).
    static var windowCyclers: [pid_t: WindowCycler] = [:]

    /// Checks if the given running application has at least one window (via AXWindows or AXMainWindow).
    static func appHasWindows(_ app: NSRunningApplication) -> Bool {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var value: CFTypeRef?
        // Try to retrieve all windows.
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)
        if result == .success, let windowArray = value as? [AXUIElement], !windowArray.isEmpty {
            return true
        }
        // Fallback: check for main window.
        var mainValue: CFTypeRef?
        let mainResult = AXUIElementCopyAttributeValue(appElement, kAXMainWindowAttribute as CFString, &mainValue)
        if mainResult == .success, mainValue != nil {
            return true
        }
        return false
    }

    static func toggleApp(mapping: ApplicationMapping) {
        print("AppSwitcher: Toggling app \(mapping.appName)")
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: mapping.bundleID)
        guard let app = runningApps.first else {
            print("AppSwitcher: App not running, launching \(mapping.appName)")
            launchApp(mapping: mapping)
            return
        }
        
        // Check if the app has any windows. If not, try to prompt new window creation.
        if !appHasWindows(app) {
            print("AppSwitcher: App \(mapping.appName) is running but has no windows. Activating app and simulating Command+N.")
            if #available(macOS 14, *) {
                app.activate(options: [.activateAllWindows])
            } else {
                app.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            }
            // Delay a short moment to allow the app to become active.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                simulateNewWindow()
            }
            return
        }
        
        // For cycle methods "next" or "stack", attempt to cycle windows.
        let method = mapping.windowBehavior.cycleMethod.lowercased()
        print("AppSwitcher: Using cycle method: \(method)")
        
        if method == "minimize" {
            simulateHideActiveApp()
        } else if method == "next" || method == "stack" {
            if let cycler = windowCyclers[app.processIdentifier] {
                print("AppSwitcher: Using existing window cycler")
                cycler.cycleToNextWindow()
            } else {
                print("AppSwitcher: Creating new window cycler")
                let cycler = WindowCycler(app: app, windowBehavior: mapping.windowBehavior)
                windowCyclers[app.processIdentifier] = cycler
                cycler.cycleToNextWindow()
            }
        } else {
            print("AppSwitcher: Simply activating app")
            app.activate(options: [.activateAllWindows])
        }
    }
    
    static func launchApp(mapping: ApplicationMapping) {
        var appURL: URL?
        if let customPath = mapping.customLaunchPath, !customPath.isEmpty {
            appURL = URL(fileURLWithPath: customPath)
        } else {
            appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mapping.bundleID)
        }
        if let url = appURL {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { (app, error) in
                if let error = error {
                    print("AppSwitcher: Failed to launch app \(mapping.appName): \(error)")
                }
            }
        }
    }
    
    static func simulateHideActiveApp() {
        guard let source = CGEventSource(stateID: .combinedSessionState) else { return }
        let keyCodeH: CGKeyCode = 4  // Key code for "H" on a US keyboard.
        let cmdFlag = CGEventFlags.maskCommand

        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeH, keyDown: true) {
            keyDown.flags = cmdFlag
            keyDown.post(tap: .cghidEventTap)
        }
        if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeH, keyDown: false) {
            keyUp.flags = cmdFlag
            keyUp.post(tap: .cghidEventTap)
        }
    }
    
    /// Simulates the Command+N keystroke to prompt new window creation.
    static func simulateNewWindow() {
        guard let source = CGEventSource(stateID: .combinedSessionState) else { return }
        // Key code for "N" on a US keyboard. (This may vary by layout.)
        let keyCodeN: CGKeyCode = 45
        let cmdFlag = CGEventFlags.maskCommand

        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeN, keyDown: true) {
            keyDown.flags = cmdFlag
            keyDown.post(tap: .cghidEventTap)
        }
        if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeN, keyDown: false) {
            keyUp.flags = cmdFlag
            keyUp.post(tap: .cghidEventTap)
        }
    }
}
