//
//  LiveSports_MenuApp.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import SwiftUI

@main
struct LiveSports_MenuApp: App {
    var body: some Scene {
        MenuBarExtra {
                    ContentView()
                        .overlay(alignment: .topTrailing) {
                                    Button(
                                        "Quit",
                                        systemImage: "xmark.circle.fill"
                                    ) {
                                        NSApp.terminate(nil)
                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.plain)
                                    .padding(6)
                                }
        } label: {
            Label {
                    Text("Live Sports Scores")
                } icon: {
                    let image: NSImage = {
                        let ratio = $0.size.height / $0.size.width
                        $0.size.height = 18
                        $0.size.width = 18 / ratio
                        return $0
                    }(NSImage(named: "BaseballIcon")!)
                    
                    Image(nsImage: image)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
