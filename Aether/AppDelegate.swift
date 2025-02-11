//
//  AppDelegate.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController!
    var configManager: ConfigManager!
    var hotKeyManager: HotKeyManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestAccessibilityPermissions()
        
        // Load configuration from ~/.config/aether/aether_config.toml
        configManager = ConfigManager()
        configManager.loadConfig()

        // Set up the status bar icon and menu.
        statusBarController = StatusBarController()
        statusBarController.onToggleEnable = { [weak self] in
            self?.toggleEnabled()
        }

        // Create and register hotkeys from our config.
        hotKeyManager = HotKeyManager(config: configManager.config,
                                      isEnabled: configManager.config.settings.quickSwitchEnabled)
        hotKeyManager.registerHotKeys()
    }
    
    /// Check and request accessibility permissions.
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            print("Accessibility permissions not granted. Please add Aether to the list in System Preferences → Security & Privacy → Privacy → Accessibility.")
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func toggleEnabled() {
        let newState = !hotKeyManager.isEnabled
        hotKeyManager.setEnabled(newState)
        statusBarController.updateEnableMenu(isEnabled: newState)
    }
}
