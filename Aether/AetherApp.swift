//
//  AetherApp.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import SwiftUI

@main
struct AetherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No main window; this is a status‑bar–only app.
        Settings {
            EmptyView()
        }
    }
}
