//
//  LiveSports_MenuApp.swift
//  LiveSports-Menu
//
//  Created by Zachary Kornbluth <github.com/zkornbluth> on 9/18/25.
//

import SwiftUI

@main
struct LiveSports_MenuApp: App {
    @StateObject private var fetcher = GameFetcher()
    @State private var showingAbout = false

    var body: some Scene {
        MenuBarExtra {
            ContentView(fetcher: fetcher, showingAbout: $showingAbout)
        } label: {
            Label {
                Text("Live Sports Scores")
            } icon: {
                let iconName = fetcher.sport.icon
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
        
        Window("About", id: "aboutWindow") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultPosition(.center)
    }
}

enum Sport: String, CaseIterable {
    case mlb
    case nfl
    case nhl
    case nba
    case epl
    
    var apiURL: String {
        switch self {
        case .mlb:
            return "https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard"
        case .nfl:
            return "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
        case .nhl:
            return "https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/scoreboard"
        case .nba:
            return "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard"
        case .epl:
            return "https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/scoreboard"
        }
    }
    
    var leagueLogo: String {
        switch self {
        case .mlb:
            return "https://a.espncdn.com/i/teamlogos/leagues/500/mlb.png"
        case .nfl:
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nfl.png"
        case .nhl:
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nhl.png"
        case .nba:
            return "https://a.espncdn.com/i/teamlogos/leagues/500/nba.png"
        case .epl:
            return "https://a.espncdn.com/i/leaguelogos/soccer/500/23.png"
        }
    }
    
    var icon: String {
        switch self {
        case .mlb:
            return "MLBIcon"
        case .nfl:
            return "FootballIcon"
        case .nhl:
            return "NHLIcon"
        case .nba:
            return "NBAIcon"
        case .epl:
            return "SoccerIcon"
        }
    }
}
