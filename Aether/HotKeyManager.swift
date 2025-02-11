//
//  HotKeyManager.swift
//  Aether
//
//  Created by Brayden Moon on 11/2/2025.
//

import AppKit
import HotKey

class HotKeyManager {
    var hotKeys: [HotKey] = []
    var config: AetherConfiguration
    var isEnabled: Bool

    init(config: AetherConfiguration, isEnabled: Bool) {
        self.config = config
        self.isEnabled = isEnabled
    }

    func registerHotKeys() {
        // Iterate over each mapping in the config.
        for mapping in config.apps where mapping.enabled {
            // Convert the first character of the configured key (e.g. "T") into a HotKey.Key.
            guard let firstChar = mapping.hotkey.key.first,
                  let key = keyFromCharacter(firstChar) else { continue }
            
            let modifiers = convertModifiers(mapping.hotkey.modifiers)
            // Initialize HotKey using the convenience initializer.
            let hotKey = HotKey(key: key, modifiers: modifiers)
            hotKey.keyDownHandler = { [weak self] in
                guard let self = self, self.isEnabled else { return }
                AppSwitcher.toggleApp(mapping: mapping)
            }
            hotKeys.append(hotKey)
        }
    }

    /// Enable or disable processing of hotkey events.
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    /// Convert an array of modifier strings (like "command", "option") to NSEvent.ModifierFlags.
    func convertModifiers(_ mods: [String]) -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        for mod in mods {
            switch mod.lowercased() {
            case "command", "cmd":
                flags.insert(.command)
            case "option", "alt":
                flags.insert(.option)
            case "control", "ctrl":
                flags.insert(.control)
            case "shift":
                flags.insert(.shift)
            default:
                break
            }
        }
        return flags
    }
    
    /// Convert a character (for example, "T") into the corresponding HotKey Key.
    func keyFromCharacter(_ char: Character) -> Key? {
        switch char.lowercased() {
        case "a": return .a
        case "b": return .b
        case "c": return .c
        case "d": return .d
        case "e": return .e
        case "f": return .f
        case "g": return .g
        case "h": return .h
        case "i": return .i
        case "j": return .j
        case "k": return .k
        case "l": return .l
        case "m": return .m
        case "n": return .n
        case "o": return .o
        case "p": return .p
        case "q": return .q
        case "r": return .r
        case "s": return .s
        case "t": return .t
        case "u": return .u
        case "v": return .v
        case "w": return .w
        case "x": return .x
        case "y": return .y
        case "z": return .z
        default: return nil
        }
    }
}
