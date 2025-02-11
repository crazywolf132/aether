//
//  ConfigManager.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import Foundation
import TOMLKit
import Cocoa

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
    
    init(cycleMethod: String, restoreLayout: Bool? = nil, groupBySpaces: Bool? = nil, followFocus: Bool? = nil) {
        self.cycleMethod = cycleMethod
        self.restoreLayout = restoreLayout
        self.groupBySpaces = groupBySpaces
        self.followFocus = followFocus
    }
}

struct ApplicationMapping: Codable {
    var appName: String
    var bundleID: String
    var enabled: Bool
    var customLaunchPath: String?
    
    // Hotkey settings
    var hotkeyKey: String
    var hotkeyModifiers: [String]
    
    // Window behavior settings
    var windowCycleMethod: String
    var windowRestoreLayout: Bool
    var windowGroupBySpaces: Bool
    var windowFollowFocus: Bool
    
    init(appName: String,
         bundleID: String,
         enabled: Bool,
         customLaunchPath: String? = nil,
         hotkeyKey: String,
         hotkeyModifiers: [String],
         windowCycleMethod: String,
         windowRestoreLayout: Bool,
         windowGroupBySpaces: Bool,
         windowFollowFocus: Bool) {
        self.appName = appName
        self.bundleID = bundleID
        self.enabled = enabled
        self.customLaunchPath = customLaunchPath
        self.hotkeyKey = hotkeyKey
        self.hotkeyModifiers = hotkeyModifiers
        self.windowCycleMethod = windowCycleMethod
        self.windowRestoreLayout = windowRestoreLayout
        self.windowGroupBySpaces = windowGroupBySpaces
        self.windowFollowFocus = windowFollowFocus
    }
    
    var hotkey: HotkeyConfiguration {
        HotkeyConfiguration(key: hotkeyKey, modifiers: hotkeyModifiers)
    }
    
    var windowBehavior: WindowBehavior {
        WindowBehavior(
            cycleMethod: windowCycleMethod,
            restoreLayout: windowRestoreLayout,
            groupBySpaces: windowGroupBySpaces,
            followFocus: windowFollowFocus
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case appName, bundleID, enabled, customLaunchPath
        case hotkeyKey, hotkeyModifiers
        case windowCycleMethod, windowRestoreLayout, windowGroupBySpaces, windowFollowFocus
    }
}

struct AetherConfiguration: Codable {
    var settings: GlobalSettings
    var apps: [ApplicationMapping]
    
    init(settings: GlobalSettings, apps: [ApplicationMapping]) {
        self.settings = settings
        self.apps = apps
    }
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
            let decoder = TOMLDecoder()
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
                        customLaunchPath: nil,
                        hotkeyKey: "T",
                        hotkeyModifiers: ["command", "option"],
                        windowCycleMethod: "next",
                        windowRestoreLayout: true,
                        windowGroupBySpaces: true,
                        windowFollowFocus: true
                    ),
                    ApplicationMapping(
                        appName: "Safari",
                        bundleID: "com.apple.Safari",
                        enabled: true,
                        customLaunchPath: nil,
                        hotkeyKey: "S",
                        hotkeyModifiers: ["command", "option"],
                        windowCycleMethod: "next",
                        windowRestoreLayout: true,
                        windowGroupBySpaces: true,
                        windowFollowFocus: true
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
