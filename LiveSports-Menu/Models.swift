//
//  Models.swift
//  LiveSports-Menu
//
//  Created by Zachary Kornbluth <github.com/zkornbluth> on 9/18/25.
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
    let links: [Link]
}

struct Link: Decodable {
    let href: String
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
    let curatedRank: Rank? // Only exists for CFB
    
    var intScore: Int {
        Int(score) ?? 0
    }
}

// Team info
struct Team: Decodable {
    let id: String
    let displayName: String
    let logo: String?
}

// Game status
struct Status: Decodable {
    let type: StatusType
}

// Rank (CFB)
struct Rank: Decodable {
    let current: Int
    
    func displayRank() -> String {
        return current == 99 ? "" : "\(current)"
    }
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
            case .mlb, .nhl, .nba, .nfl, .cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec:
                // MLB, NHL, NBA are all the same - just want the time
                // NFL/CFB are almost the same, but add the weekday from detail
                let range = shortDetail.range(of: " - ")
                if range != nil {
                    let timeWithTimezone = String(shortDetail[range!.upperBound...])
                    let weekday: String
                    if [.nfl, .cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec].contains(sport) {
                        weekday = detail.prefix(3) + " "
                    } else {
                        // If there's no games today, ESPN scoreboard may show a later day's schedule
                        // In that case, we want to show that date before the games so user doesn't think they're today
                        let today = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd"
                        var formattedDate = dateFormatter.string(from: today)

                        // Remove leading zeros - API returns 9/1 or 10/1 not 09/01 or 10/01
                        // Check string indices 0 and 3, remove if they're "0"
                        // 3 first, in case it's removed it won't affect 0
                        for indexToCheck in [3, 0] {
                            let indexToRemove = formattedDate.index(formattedDate.startIndex, offsetBy: indexToCheck)
                            
                            if formattedDate[indexToRemove] == "0" {
                                formattedDate.remove(at: indexToRemove)
                            }
                        }
                        let scheduledDate = shortDetail[..<range!.lowerBound]
                        if scheduledDate != formattedDate {
                            weekday = scheduledDate + " "
                        } else {
                            weekday = ""
                        }
                    }
                    return weekday + String(timeWithTimezone.dropLast(4)) // drop timezone and leading space
                }
            case .epl:
                // EPL has scheduled time only in detail, not shortDetail
                // Also has no -, need to split around " at "
                let range = detail.range(of: " at ")
                if range != nil {
                    let timeWithTimezone = String(detail[range!.upperBound...])
                    let weekday = detail.prefix(3) + " "
                    return weekday + String(timeWithTimezone.dropLast(4))
                }
            }
        } else if shortDetail.prefix(10) == "Rain Delay" {
            // in progress, it follows this format: Rain Delay - Top 1st
            // widens the screen if we show everything, so just show Rain Delay
            return "Rain Delay"
        } else if shortDetail.prefix(7) == "Delayed" {
            // same as above
            return "Delayed"
        }
        // Otherwise - game is in progress or over, just return shortDetail for all sports
        return shortDetail
    }
}
