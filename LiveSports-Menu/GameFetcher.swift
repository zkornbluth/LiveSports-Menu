//
//  GameFetcher.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import Foundation

@MainActor
class GameFetcher: ObservableObject {
    @Published var events: [Event] = []
    
    func loadTodayGames() {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard") else {
            print("Invalid ESPN URL")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let scoreboard = try decoder.decode(ScoreboardResponse.self, from: data)
                self.events = scoreboard.events
                print("Loaded \(scoreboard.events.count) games")
            } catch {
                print("Error fetching ESPN JSON: \(error)")
            }
        }
    }
}
