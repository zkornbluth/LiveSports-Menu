//
//  AppDelegate.swift
//  LiveSports-Menu
//
//  Created by Cursor on 3/5/26.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MainActor.assumeIsolated {
            StatusItemController.shared = StatusItemController()
        }
        DispatchQueue.main.async {
            for window in NSApp.windows {
                let id = window.identifier?.rawValue ?? ""
                if id == "aboutWindow" || id == "keyboardShortcutWindow" {
                    window.close()
                }
            }
        }
    }
}
