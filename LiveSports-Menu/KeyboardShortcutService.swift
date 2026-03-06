//
//  KeyboardShortcutService.swift
//  LiveSports-Menu
//
//  Created by Cursor on 3/5/26.
//

import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleLiveSportsMenu = Self(
        "ToggleLiveSportsMenu",
        default: .init(.l, modifiers: [.control, .option])
    )
}

private enum ShortcutKeys {
    static let isToggleLiveSportsMenuEnabled = "isToggleLiveSportsMenuEnabled"
}

@MainActor
class KeyboardShortcutService: ObservableObject {
    static let shared = KeyboardShortcutService()
    
    private init() { }
    
    private static let defaults = UserDefaults.standard
    
    @Published var isToggleLiveSportsMenuEnabled: Bool = {
        defaults.bool(forKey: ShortcutKeys.isToggleLiveSportsMenuEnabled)
    }() {
        didSet {
            KeyboardShortcutService.defaults.set(
                isToggleLiveSportsMenuEnabled,
                forKey: ShortcutKeys.isToggleLiveSportsMenuEnabled
            )
            setEnabled(isToggleLiveSportsMenuEnabled, for: .toggleLiveSportsMenu)
        }
    }
    
    func action(for shortcutName: KeyboardShortcuts.Name, action: @escaping () -> Void) {
        KeyboardShortcuts.onKeyDown(for: shortcutName) {
            action()
        }
        let isEnabled = isEnabled(shortcutName)
        setEnabled(isEnabled, for: shortcutName)
    }
    
    func reset(_ shortcutName: KeyboardShortcuts.Name) {
        KeyboardShortcuts.reset(shortcutName)
    }
    
    private func isEnabled(_ shortcutName: KeyboardShortcuts.Name) -> Bool {
        switch shortcutName {
        case .toggleLiveSportsMenu:
            return isToggleLiveSportsMenuEnabled
        default:
            return false
        }
    }
    
    private func setEnabled(_ isEnabled: Bool, for shortcutName: KeyboardShortcuts.Name) {
        if isEnabled {
            KeyboardShortcuts.enable(shortcutName)
        } else {
            KeyboardShortcuts.disable(shortcutName)
        }
    }
}

