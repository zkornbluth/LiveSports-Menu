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
    
    var displayTimeOnly: String {
        // If shortDetail contains " - ", take the part after it
        if let range = shortDetail.range(of: " - ") {
            return String(shortDetail[range.upperBound...])
        }
        // Otherwise just return whatever ESPN sent
        return shortDetail
    }
}
