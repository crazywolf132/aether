//
//  ConfigManager.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import Foundation
import TOMLKit

// MARK: - Configuration Data Structures

struct GlobalSettings: Codable {
    var quickSwitchEnabled: Bool
}

struct HotkeyConfiguration: Codable {
    var key: String           // e.g., "T"
    var modifiers: [String]   // e.g., ["command", "option"]
}

struct WindowBehavior: Codable {
    var cycleMethod: String   // e.g., "next", "stack", "minimize", or "script:..."
    var restoreLayout: Bool?    // Optional: restore previous window layout
    var groupBySpaces: Bool?    // Optional: cycle only among windows in the current space
    var followFocus: Bool?      // Optional: automatically follow focus across spaces
}

struct ApplicationMapping: Codable {
    var appName: String
    var bundleID: String
    var enabled: Bool
    var hotkey: HotkeyConfiguration
    var customLaunchPath: String?
    var windowBehavior: WindowBehavior
}

struct AetherConfiguration: Codable {
    var settings: GlobalSettings
    var apps: [ApplicationMapping]
}

class ConfigManager {
    var config: AetherConfiguration!
    let configURL: URL
    var configSource: DispatchSourceFileSystemObject?
    
    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let configDir = home.appendingPathComponent(".config/aether")
        try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true, attributes: nil)
        configURL = configDir.appendingPathComponent("aether_config.toml")
        
        // Begin watching the file for changes
        startWatching()
    }
    
    func loadConfig() {
        do {
            let data = try Data(contentsOf: configURL)
            let tomlString = String(decoding: data, as: UTF8.self)
            let decoder = TOMLDecoder()  // Using TOMLKit’s decoder
            config = try decoder.decode(AetherConfiguration.self, from: tomlString)
            print("ConfigManager: Loaded configuration with \(config.apps.count) apps.")
        } catch {
            print("Failed to load config: \(error)")
            // Fall back to a default configuration.
            config = AetherConfiguration(
                settings: GlobalSettings(quickSwitchEnabled: true),
                apps: [
                    ApplicationMapping(
                        appName: "Terminal",
                        bundleID: "com.apple.Terminal",
                        enabled: true,
                        hotkey: HotkeyConfiguration(key: "T", modifiers: ["command", "option"]),
                        customLaunchPath: nil,
                        windowBehavior: WindowBehavior(cycleMethod: "next", restoreLayout: true, groupBySpaces: true, followFocus: true)
                    ),
                    ApplicationMapping(
                        appName: "Safari",
                        bundleID: "com.apple.Safari",
                        enabled: true,
                        hotkey: HotkeyConfiguration(key: "S", modifiers: ["command", "option"]),
                        customLaunchPath: nil,
                        windowBehavior: WindowBehavior(cycleMethod: "next", restoreLayout: true, groupBySpaces: true, followFocus: true)
                    )
                ]
            )
        }
    }
    
    private func startWatching() {
        // Open a file descriptor for the config file.
        let fileDescriptor = open(configURL.path, O_EVTONLY)
        if fileDescriptor < 0 {
            print("ConfigManager: Could not open file descriptor for config file.")
            return
        }
        configSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.global())
        configSource?.setEventHandler { [weak self] in
            print("ConfigManager: Detected a config change, reloading...")
            self?.loadConfig()
        }
        configSource?.setCancelHandler {
            close(fileDescriptor)
        }
        configSource?.resume()
    }
}
