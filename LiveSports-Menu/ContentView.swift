//
//  ContentView.swift
//  LiveSports-Menu
//
//  Created by Zachary Kornbluth <github.com/zkornbluth> on 9/18/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fetcher: GameFetcher
    @Binding var showingAbout: Bool
    @Environment(\.openWindow) var openWindow
    @State private var showNoEvents = false
    
    var body: some View {
        VStack(spacing: 8) {
            if fetcher.events.isEmpty {
                Text(showNoEvents ? "No scheduled games today" : "Loading…")
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        showNoEvents = true
                    }
            } else {
                ForEach(fetcher.events) { event in
                    GameRowView(event: event, sport: fetcher.sport)
                }
            }
            Divider()
                .frame(maxWidth: 182)
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
                        Picker("College Football", selection: $fetcher.sport) {
                            Text("Top 25").tag(Sport.cfbt25)
                            Text("ACC").tag(Sport.cfbacc)
                            Text("Big Ten").tag(Sport.cfbbig10)
                            Text("Big 12").tag(Sport.cfbbig12)
                            Text("SEC").tag(Sport.cfbsec)
                        }
                    }
                    Divider()
                    Button("About") {
                        // Try multiple approaches to open the window
                        openWindow(id: "aboutWindow")
                        
                        // Alternative approach using NSApp
                        DispatchQueue.main.async {
                            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "aboutWindow" }) {
                                window.makeKeyAndOrderFront(nil)
                                NSApp.activate(ignoringOtherApps: true)
                            }
                        }
                    }
                    Button("Quit") { NSApp.terminate(nil) }
                } label: {
                    Image(systemName: "gear")
                        .padding(4)
                }
                .menuStyle(.borderlessButton)
                .frame(maxWidth: 182, alignment: .trailing)
                .fixedSize()
            }
            .onChange(of: fetcher.sport) { newSport, _ in
                showNoEvents = false
                Task {
                    await fetcher.switchSport(to: newSport)
                }
            }
            .frame(maxWidth: 182)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .task {
            await fetcher.loadTodayGames()
        }
    }
}

struct GameRowView: View {
    @Environment(\.openURL) var openURL
    let event: Event
    let sport: Sport
    
    var body: some View {
        if let competition = event.competitions.first {
            let away = competition.competitors.first { $0.homeAway == "away" }
            let home = competition.competitors.first { $0.homeAway == "home" }
            
            if let away = away, let home = home {
                let statusText = event.status.type.displayStatus(for: sport)
                let gameNotStarted = event.status.type.state == "pre"
                
                HStack(spacing: 6) {
                    if [.cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec].contains(sport) {
                        // Away team rank (99 represents unranked, don't show)
                        Text(away.curatedRank?.displayRank() ?? "")
                            .font(.footnote)
                            .frame(minWidth: 15)
                    }
                    let awayLogo = (away.team.logo == nil || away.team.logo == "") ? sport.leagueLogo : away.team.logo
                    AsyncImage(url: URL(string: awayLogo ?? sport.leagueLogo)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .help(away.team.displayName)
                    .frame(width: 24, height: 24)
                    Button {
                        if let url = URL(string: event.links[0].href) {
                            openURL(url)
                        }
                    } label: {
                        if gameNotStarted {
                            Text(statusText)
                                .font(.footnote)
                                .frame(minWidth: 122, alignment: .center)
                        } else {
                            Text("\(away.intScore)")
                                .font(.subheadline)
                                .frame(width: 25, alignment: .trailing)
                            
                            Text(statusText)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .frame(minWidth: 60, alignment: .center)
                            
                            Text("\(home.intScore)")
                                .font(.subheadline)
                                .frame(width: 25, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    let homeLogo = (home.team.logo == nil || home.team.logo == "") ? sport.leagueLogo : home.team.logo
                    AsyncImage(url: URL(string: homeLogo ?? sport.leagueLogo)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .help(home.team.displayName)
                    .frame(width: 24, height: 24)
                    if [.cfbt25, .cfbacc, .cfbbig10, .cfbbig12, .cfbsec].contains(sport) {
                        // Home team rank (99 represents unranked, don't show)
                        Text(home.curatedRank?.displayRank() ?? "")
                            .font(.footnote)
                            .frame(minWidth: 15)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(fetcher: GameFetcher(), showingAbout: .constant(false))
        .frame(minWidth: 180, minHeight: 650)
}
