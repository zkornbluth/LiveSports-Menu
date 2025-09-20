//
//  GameFetcher.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import Foundation
import SwiftUI

@MainActor
class GameFetcher: ObservableObject {
    @Published var events: [Event] = []
    @Published var sport: Sport = .mlb

    func loadTodayGames() async {
        guard let url = URL(string: sport.apiURL) else {
            print("Invalid ESPN URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let scoreboard = try decoder.decode(ScoreboardResponse.self, from: data)
            self.events = scoreboard.events
        } catch {
            print("Error fetching ESPN JSON: \(error)")
        }
    }

    func switchSport(to sport: Sport) async {
        self.events = []
        await loadTodayGames()
    }
}
