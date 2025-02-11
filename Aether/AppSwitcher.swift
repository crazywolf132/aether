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

    static func toggleApp(mapping: ApplicationMapping) {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: mapping.bundleID)
        guard let app = runningApps.first else {
            launchApp(mapping: mapping)
            return
        }
        
        // For cycle methods "next" or "stack", attempt to cycle windows.
        let method = mapping.windowBehavior.cycleMethod.lowercased()
        if method == "minimize" {
            simulateHideActiveApp()
        } else if method == "next" || method == "stack" {
            if let cycler = windowCyclers[app.processIdentifier] {
                cycler.cycleToNextWindow()
            } else {
                let cycler = WindowCycler(app: app)
                windowCyclers[app.processIdentifier] = cycler
                cycler.cycleToNextWindow()
            }
        } else {
            // For any other configuration, simply activate the app.
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
        let keyCodeH: CGKeyCode = 4  // key code for "H" on a US keyboard.
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
}
