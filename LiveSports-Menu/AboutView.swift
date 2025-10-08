//
//  AboutView.swift
//  LiveSports-Menu
//
//  Created by Zachary Kornbluth <github.com/zkornbluth> on 9/20/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        VStack(spacing: 10) {
            if let appIcon = NSApp.applicationIconImage {
                Image(nsImage: appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            } else {
                // Fallback to your custom image
                Image("App_Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            Text("LiveSports-Menu")
                .font(.title)
                .fontWeight(.bold)
            Text("by Zachary Kornbluth")
            Text("Version 1.2")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Divider()
            Button(action: {
                if let url = URL(string: "https://github.com/zkornbluth/LiveSports-Menu") {
                    openURL(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image("github")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("GitHub")
                }
            }
            Divider()
            Button("Close") {
                if let window = NSApp.keyWindow {
                    window.close()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .frame(width: 300, height: 250)
    }
}

#Preview {
    AboutView()
}
