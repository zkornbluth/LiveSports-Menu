//
//  StatusItemController.swift
//  LiveSports-Menu
//
//  Created by Cursor on 3/5/26.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    static var shared: StatusItemController?
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private var sportObserver: AnyCancellable?
    
    override init() {
        super.init()
        guard let button = statusItem.button else { return }
        
        updateButtonIcon()
        button.target = self
        button.action = #selector(togglePopover)
        
        popover.contentSize = NSSize(width: 220, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView(
                fetcher: GameFetcher.shared,
                showingAbout: .constant(false)
            )
        )
        
        sportObserver = GameFetcher.shared.$sport
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateButtonIcon() }
    }
    
    private func updateButtonIcon() {
        let iconName = GameFetcher.shared.sport.icon
        guard let img = NSImage(named: iconName) else { return }
        let ratio = img.size.height / img.size.width
        img.size.height = 18
        img.size.width = 18 / ratio
        statusItem.button?.image = img
        statusItem.button?.toolTip = "Live Sports Scores"
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
