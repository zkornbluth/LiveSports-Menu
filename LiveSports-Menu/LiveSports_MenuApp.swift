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
    case cfbt25
    case cfbacc
    case cfbbig10
    case cfbbig12
    case cfbsec
    
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
        case .cfbt25:
            return "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard"
        case .cfbacc:
            return "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?groups=1"
        case .cfbbig10:
            return "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?groups=5"
        case .cfbbig12:
            return "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?groups=4"
        case .cfbsec:
            return "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?groups=8"
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
        case .cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec:
            return "https://a.espncdn.com/redesign/assets/img/icons/ESPN-icon-football-college.png"
        }
    }
    
    var icon: String {
        switch self {
        case .mlb:
            return "MLBIcon"
        case .nfl, .cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec:
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
