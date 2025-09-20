//
//  ContentView.swift
//  LiveSports-Menu
//
//  Created by Zach Kornbluth on 9/18/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fetcher: GameFetcher
    
    var body: some View {
        VStack(spacing: 8) {
            if fetcher.events.isEmpty {
                Text("Loading…")
            } else {
                ForEach(fetcher.events) { event in
                    GameRowView(event: event, sport: fetcher.sport)
                }
            }
            Divider()
                .frame(maxWidth: 166)
            HStack {
                Spacer()
                Text("All times in EDT")
                    .font(.footnote)
                Menu {
                    Picker("Change Sport", selection: $fetcher.sport) {
                        Text("MLB").tag(Sport.mlb)
                        Text("NFL").tag(Sport.nfl)
                        Text("NHL").tag(Sport.nhl)
                        Text("NBA").tag(Sport.nba)
                        Text("Premier League").tag(Sport.epl)
                    }
                    Divider()
                    Button("Quit") { NSApp.terminate(nil) }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .padding(4)
                }
                .menuStyle(.borderlessButton)
                .frame(maxWidth: 166, alignment: .trailing)
                .fixedSize()
            }
            .onChange(of: fetcher.sport) { newSport, _ in
                Task {
                    await fetcher.switchSport(to: newSport)
                }
            }
            .frame(maxWidth: 166)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .task {
            await fetcher.loadTodayGames()
        }
    }
}

struct GameRowView: View {
    let event: Event
    let sport: Sport
    
    var body: some View {
        if let competition = event.competitions.first {
            let away = competition.competitors.first { $0.homeAway == "away" }
            let home = competition.competitors.first { $0.homeAway == "home" }
            
            if let away = away, let home = home {
                let statusText = event.status.type.displayStatus(for: sport)
                let gameNotStarted = statusText.contains("AM") || statusText.contains("PM")
                
                HStack(spacing: 6) {
                    let awayLogo = away.team.logo == "" ? sport.leagueLogo : away.team.logo
                    AsyncImage(url: URL(string: awayLogo)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 24, height: 24)
                    
                    if gameNotStarted {
                        Text(statusText)
                            .font(.footnote)
                            .frame(minWidth: 102, alignment: .center)
                    } else {
                        Text("\(away.intScore)")
                            .font(.subheadline)
                            .frame(width: 20, alignment: .trailing)
                        
                        Text(statusText)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(minWidth: 50, alignment: .center)
                        
                        Text("\(home.intScore)")
                            .font(.subheadline)
                            .frame(width: 20, alignment: .leading)
                    }
                    
                    let homeLogo = home.team.logo == "" ? sport.leagueLogo : home.team.logo
                    AsyncImage(url: URL(string: homeLogo)) { image in
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

#Preview {
    ContentView(fetcher: GameFetcher())
        .frame(minHeight: 550)
}
