//
//  ViewCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct ViewCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .toolbar) {
            Section {
                Button {
                    NSApplication.shared.mainWindow?.toggleFullScreen(nil)
                } label: {
                    Text("Toggle Full Screen")
                }
                .keyboardShortcut(.return, modifiers: [])
            }
        }
    }
}

