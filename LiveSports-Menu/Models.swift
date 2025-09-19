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
    
    var displayTimeOnly: String {
        return displayTime(for: .mlb) // Default to MLB behavior
    }
    
    func displayTime(for sport: Sport) -> String {
        // If shortDetail contains " - ", take the part after it
        if let range = shortDetail.range(of: " - ") {
            let timeWithTimezone = String(shortDetail[range.upperBound...]) // "10:10 PM EDT"
            
            // Remove timezone (EDT, EST, PDT, PST, etc.) - any 3-letter word at the end
            let components = timeWithTimezone.components(separatedBy: " ")
            let timeOnly = if components.count > 1, let lastComponent = components.last, lastComponent.count == 3 {
                components.dropLast().joined(separator: " ")
            } else {
                timeWithTimezone
            }
            
            // For NFL, add day of week from the detail field
            // But only if the detail actually contains a day (ends with comma)
            if sport == .nfl, !detail.isEmpty, detail.contains(",") {
                let dayOfWeek = String(detail.prefix(3)) // Get first 3 characters
                return "\(dayOfWeek) \(timeOnly)"
            } else {
                return timeOnly
            }
        }
        // Otherwise just return whatever ESPN sent
        return shortDetail
    }
}
