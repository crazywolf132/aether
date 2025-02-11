# Aether

Aether is a lightweight macOS utility that enhances window management and application switching through customizable keyboard shortcuts. It runs quietly in your menu bar, providing quick access to window management features.

## Features

- Menu bar interface for easy access and control
- Customizable keyboard shortcuts for window management
- Quick application switching functionality
- Configuration via TOML file (`~/.config/aether/aether_config.toml`)

## Requirements

- macOS
- Accessibility permissions (required for window management)

## Installation

1. Download and open Aether
2. Grant accessibility permissions when prompted
3. The app will appear in your menu bar

## Configuration Guide

Aether is configured through a TOML file located at `~/.config/aether/aether_config.toml`. This section explains how to customize Aether to suit your needs.

### Configuration File Location

The configuration file should be placed at:
```
~/.config/aether/aether_config.toml
```

If the directory doesn't exist, create it using:
```bash
mkdir -p ~/.config/aether
```

### Global Settings

The global settings section controls the overall behavior of Aether:

```toml
[settings]
quickSwitchEnabled = true  # Enable/disable all hotkeys globally
```

| Setting | Type | Description |
|---------|------|-------------|
| `quickSwitchEnabled` | Boolean | When set to `false`, temporarily disables all hotkeys without quitting the app |

### Application Configuration

Each application is configured in its own `[[apps]]` section. Here's a complete example with all available options:

```toml
[[apps]]
appName = "Terminal"                              # Display name of the application
bundleID = "com.apple.Terminal"                   # Bundle identifier
enabled = true                                    # Enable/disable this configuration
customLaunchPath = "/Applications/Terminal.app"   # Optional: Custom app location
hotkeyKey = "T"                                  # Single character hotkey
hotkeyModifiers = ["command", "option"]          # Modifier keys for the hotkey
windowCycleMethod = "next"                       # Window cycling behavior
windowRestoreLayout = true                       # Remember window positions
windowGroupBySpaces = true                       # Cycle within current space only
windowFollowFocus = true                         # Follow windows across spaces
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `appName` | String | Display name of the application |
| `bundleID` | String | Bundle identifier of the application |
| `enabled` | Boolean | Whether this configuration is active |
| `hotkeyKey` | String | Single character key for the hotkey |
| `hotkeyModifiers` | Array of Strings | List of modifier keys |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `customLaunchPath` | String | Custom path to the application |

#### Window Behavior Settings

| Field | Type | Options | Description |
|-------|------|---------|-------------|
| `windowCycleMethod` | String | "next", "stack", "minimize" | How windows should be cycled |
| `windowRestoreLayout` | Boolean | true/false | Remember and restore window positions |
| `windowGroupBySpaces` | Boolean | true/false | Only cycle through windows in current space |
| `windowFollowFocus` | Boolean | true/false | Automatically follow focus across spaces |

### Hotkey Configuration

The hotkey system combines a single character key with modifier keys:

#### Available Modifier Keys
- `"command"` (⌘)
- `"option"`  (⌥)
- `"control"` (⌃)
- `"shift"`   (⇧)

Example combinations:
```toml
# Command + Option + T
hotkeyKey = "T"
hotkeyModifiers = ["command", "option"]

# Command + Control + Shift + V
hotkeyKey = "V"
hotkeyModifiers = ["command", "control", "shift"]
```

### Window Cycling Methods

Three window cycling methods are available:

| Method | Description | Best For |
|--------|-------------|----------|
| `"next"` | Cycle through windows in order | Apps where window order matters |
| `"stack"` | Cycle based on most recently used | Browsers and document-based apps |
| `"minimize"` | Minimize the current window | Apps you frequently want to hide |

### Example Configurations

#### Browser Configuration
```toml
[[apps]]
appName = "Safari"
bundleID = "com.apple.Safari"
enabled = true
hotkeyKey = "S"
hotkeyModifiers = ["command", "option"]
windowCycleMethod = "stack"
windowRestoreLayout = false
windowGroupBySpaces = false
windowFollowFocus = false
```

#### Development Environment
```toml
[[apps]]
appName = "Visual Studio Code"
bundleID = "com.microsoft.VSCode"
enabled = true
hotkeyKey = "V"
hotkeyModifiers = ["command", "option", "shift"]
windowCycleMethod = "next"
windowRestoreLayout = true
windowGroupBySpaces = true
windowFollowFocus = true
```

### Common Bundle IDs

To find an app's bundle ID, use:
```bash
osascript -e 'id of app "Application Name"'
```

Common bundle IDs:
- Terminal: `com.apple.Terminal`
- Safari: `com.apple.Safari`
- Chrome: `com.google.Chrome`
- VS Code: `com.microsoft.VSCode`
- Finder: `com.apple.finder`
- iTerm: `com.googlecode.iterm2`
- Slack: `com.slack.Slack`

### Tips and Best Practices

1. **Hotkeys**
   - Each hotkey must be unique
   - Case matters: "t" is different from "T"
   - Avoid system shortcuts to prevent conflicts

2. **Spaces Behavior**
   - `windowGroupBySpaces` and `windowFollowFocus` require accessibility permissions
   - Works best with "Displays have separate Spaces" enabled in System Settings

3. **Performance**
   - Having too many apps configured may impact performance
   - Disable unused configurations by setting `enabled = false`

4. **Configuration Changes**
   - Aether automatically detects configuration changes
   - No need to restart the app when modifying the config file

## Technical Details

Built with:
- SwiftUI
- Cocoa
- Swift

## Privacy & Permissions

Aether requires accessibility permissions to manage windows. These permissions can be granted through System Preferences → Security & Privacy → Privacy → Accessibility.

## Development Status

This is a work in progress. Features and configuration options may change.

## License

[License information to be added] 