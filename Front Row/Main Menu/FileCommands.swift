//
//  FileCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct FileCommands: Commands {
    @Binding var isPresentingOpenURLView: Bool

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

                Button {
                    isPresentingOpenURLView.toggle()
                } label: {
                    Text(
                        "Open URL...",
                        comment: "Show the open URL dialog"
                    )
                }
                .keyboardShortcut("L", modifiers: [.command])
            }
        }
    }
}
