//
//  KeyboardShortcutView.swift
//  LiveSports-Menu
//
//  Created by Cursor on 3/5/26.
//

import SwiftUI
import KeyboardShortcuts

struct KeyboardShortcutView: View {
    @ObservedObject var keyboardShortcutService = KeyboardShortcutService.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Toggle(
                        "Enable keyboard shortcut to open LiveSports-Menu",
                        isOn: $keyboardShortcutService.isToggleLiveSportsMenuEnabled
                    )
                    
                    Group {
                        HStack {
                            KeyboardShortcuts.Recorder(for: .toggleLiveSportsMenu)
                            
                            Button {
                                KeyboardShortcutService.shared.reset(.toggleLiveSportsMenu)
                            } label: {
                                Text("Restore default")
                                    .padding(.horizontal, 4)
                                    .frame(minWidth: 113)
                            }
                        }
                    }
                    .padding(.leading, 20)
                    .disabled(!keyboardShortcutService.isToggleLiveSportsMenuEnabled)
                }
                
                Spacer()
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        .padding(.horizontal, 32)
        .frame(width: 520, height: 180)
    }
}

#Preview {
    KeyboardShortcutView()
}

