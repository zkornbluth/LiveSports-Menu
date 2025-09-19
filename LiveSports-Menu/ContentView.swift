//
//  ContentView.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var fetcher = GameFetcher()
    
    var body: some View {
        VStack {
            if fetcher.events.isEmpty {
                Text("Loading…")
            } else {
                ForEach(fetcher.events) { event in
                    if let competition = event.competitions.first {
                        let away = competition.competitors.first { $0.homeAway == "away" }
                        let home = competition.competitors.first { $0.homeAway == "home" }
                        
                        if let away = away, let home = home {
                            HStack {
                                AsyncImage(url: URL(string: away.team.logo)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 24, height: 24)
                                
                                Text("\(away.intScore)")
                                    .frame(width: 20, alignment: .trailing)
                                
                                Text(event.status.type.displayTimeOnly)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .frame(width: 90, alignment: .center)
                                
                                Text("\(home.intScore)")
                                    .frame(width: 20, alignment: .leading)
                                
                                AsyncImage(url: URL(string: home.team.logo)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            fetcher.loadTodayGames()
        }
        .padding()
        .background(Color(.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
