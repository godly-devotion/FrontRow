//
//  FileCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct FileCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Section {
                Button {
                    Task { await PlayEngine.shared.showOpenFileDialog() }
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
