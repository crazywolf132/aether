//
//  StatusBarController.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//


import AppKit

class StatusBarController {
    let statusItem: NSStatusItem
    var onToggleEnable: (() -> Void)?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Aether")
        }
        constructMenu(isEnabled: true)
    }

    func constructMenu(isEnabled: Bool) {
        let menu = NSMenu()
        let enableTitle = isEnabled ? "Disable Aether" : "Enable Aether"
        let enableItem = NSMenuItem(title: enableTitle, action: #selector(toggleEnable), keyEquivalent: "")
        enableItem.target = self
        menu.addItem(enableItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Aether", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func toggleEnable() {
        onToggleEnable?()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func updateEnableMenu(isEnabled: Bool) {
        constructMenu(isEnabled: isEnabled)
    }
}
