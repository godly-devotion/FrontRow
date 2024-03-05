//
//  FileCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct FileCommands: Commands {
    var playEngine: PlayEngine
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Section {
                Button {
                    Task { await playEngine.showOpenFileDialog() }
                } label: {
                    Text(
                        "Open File...",
                        comment: "Show the open file dialog"
                    )
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
    }
}
