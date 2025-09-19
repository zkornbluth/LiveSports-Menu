//
//  LiveSports_MenuApp.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import SwiftUI

@main
struct LiveSports_MenuApp: App {
    @StateObject private var fetcher = GameFetcher()
    @State private var currentSport: Sport = .mlb

    var body: some Scene {
        MenuBarExtra {
            ContentView(fetcher: fetcher, currentSport: $currentSport)
        } label: {
            Label {
                Text("Live Sports Scores")
            } icon: {
                let iconName = currentSport == .mlb ? "MLBIcon" : "NFLIcon"
                let image: NSImage = {
                    let img = NSImage(named: iconName)!
                    let ratio = img.size.height / img.size.width
                    img.size.height = 18
                    img.size.width = 18 / ratio
                    return img
                }()
                Image(nsImage: image)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

enum Sport: String, CaseIterable {
    case mlb
    case nfl

    var apiURL: String {
        switch self {
        case .mlb:
            return "https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard"
        case .nfl:
            return "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
        }
    }
}
