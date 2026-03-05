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
    
    /// Convert a time string that is in Eastern time (as returned by the ESPN API)
    /// into the user's local time zone, preserving the time and adding the local
    /// time zone abbreviation (e.g. "7:00 PM EST" -> "4:00 PM PST").
    private func convertEasternTimeToLocal(timeWithTimezone: String, scheduledDate: String?) -> String {
        let trimmedTime = timeWithTimezone.trimmingCharacters(in: .whitespaces)
        if trimmedTime.isEmpty {
            return trimmedTime
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        // Build a date string that includes year, month, and day so that DST
        // is handled correctly for future/past games as well.
        let easternFormatter = DateFormatter()
        easternFormatter.locale = Locale(identifier: "en_US_POSIX")
        easternFormatter.timeZone = TimeZone(identifier: "America/New_York")
        
        let month: Int
        let day: Int
        
        if let scheduledDate = scheduledDate, !scheduledDate.isEmpty {
            // scheduledDate is in "M/d" or "MM/dd" form as returned by the API
            let parts = scheduledDate.split(separator: "/")
            if parts.count == 2,
               let m = Int(parts[0]),
               let d = Int(parts[1]) {
                month = m
                day = d
            } else {
                month = calendar.component(.month, from: now)
                day = calendar.component(.day, from: now)
            }
        } else {
            // Fall back to today's date if we don't have a scheduled date
            month = calendar.component(.month, from: now)
            day = calendar.component(.day, from: now)
        }
        
        let baseDateString = "\(currentYear) \(month)/\(day) "
        var date: Date? = nil
        
        // First, try parsing when the time string includes an explicit timezone (e.g. "7:00 PM EDT")
        easternFormatter.dateFormat = "yyyy M/d h:mm a zzz"
        date = easternFormatter.date(from: baseDateString + trimmedTime)
        
        // If that fails, try without an explicit timezone (e.g. "7:00 PM")
        if date == nil {
            easternFormatter.dateFormat = "yyyy M/d h:mm a"
            date = easternFormatter.date(from: baseDateString + trimmedTime)
        }
        
        // If parsing still fails, just fall back to the original time string without modification
        guard let easternDate = date else {
            return trimmedTime
        }
        
        let localFormatter = DateFormatter()
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.timeZone = TimeZone.current
        localFormatter.dateFormat = "h:mm a z"
        
        return localFormatter.string(from: easternDate)
    }
    
    func displayStatus(for sport: Sport) -> String {
        // If state is "pre" - game hasn't started yet
        if self.state == "pre" {
            switch sport {
            case .mlb, .nhl, .nba, .nfl, .cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec:
                // MLB, NHL, NBA are all the same - just want the time
                // NFL/CFB are almost the same, but add the weekday from detail
                let range = shortDetail.range(of: " - ")
                if let range = range {
                    let timeWithTimezone = String(shortDetail[range.upperBound...])
                    let scheduledDateRaw = String(shortDetail[..<range.lowerBound])
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
                        if scheduledDateRaw != formattedDate {
                            weekday = scheduledDateRaw + " "
                        } else {
                            weekday = ""
                        }
                    }
                    let localTime = convertEasternTimeToLocal(timeWithTimezone: timeWithTimezone,
                                                              scheduledDate: scheduledDateRaw)
                    return weekday + localTime
                }
            case .epl:
                // EPL has scheduled time only in detail, not shortDetail
                // Also has no -, need to split around " at "
                let range = detail.range(of: " at ")
                if let range = range {
                    let timeWithTimezone = String(detail[range.upperBound...])
                    let weekday = detail.prefix(3) + " "
                    let localTime = convertEasternTimeToLocal(timeWithTimezone: timeWithTimezone,
                                                              scheduledDate: nil)
                    return weekday + localTime
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
