//
//  Models.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import Foundation

// Root response
struct ScoreboardResponse: Decodable {
    let events: [Event]
}

// One game
struct Event: Decodable, Identifiable {
    let id: String
    let competitions: [Competition]
    let status: Status
}

// Competition (wraps the actual competitors)
struct Competition: Decodable {
    let competitors: [Competitor]
}

// Each competitor (home or away)
struct Competitor: Decodable, Identifiable {
    let id: String
    let homeAway: String
    let team: Team
    let score: String
    
    var intScore: Int {
        Int(score) ?? 0
    }
}

// Team info
struct Team: Decodable {
    let id: String
    let displayName: String
    let logo: String
}

// Game status
struct Status: Decodable {
    let type: StatusType
}

struct StatusType: Decodable {
    let shortDetail: String
    let detail: String
    let state: String
    
    var statusStr: String {
        return displayStatus(for: .mlb) // Default to MLB behavior
    }
    
    func displayStatus(for sport: Sport) -> String {
        // If state is "pre" - game hasn't started yet
        if self.state == "pre" {
            switch sport {
            case .mlb, .nhl, .nba, .nfl:
                // MLB, NHL, NBA are all the same - just want the time
                // NFL is almost the same, but add the weekday from detail
                let range = shortDetail.range(of: " - ")
                if range != nil {
                    let timeWithTimezone = String(shortDetail[range!.upperBound...])
                    let weekday: String
                    if sport == .nfl {
                        weekday = detail.prefix(3) + " "
                    } else {
                        weekday = ""
                    }
                    return weekday + String(timeWithTimezone.dropLast(4)) // drop timezone and leading space
                }
            case .epl:
                // EPL has scheduled time only in detail, not shortDetail
                // Also has no -, need to split around " at "
                let range = detail.range(of: " at ")
                if range != nil {
                    let timeWithTimezone = String(detail[range!.upperBound...])
                    let weekday = detail.prefix(3)
                    return weekday + " " + String(timeWithTimezone.dropLast(4))
                }
            }
        }
        // Otherwise - game is in progress or over, just return shortDetail
        return shortDetail
    }
}
