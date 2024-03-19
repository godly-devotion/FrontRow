//
//  WindowCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/18/24.
//

import SwiftUI

struct WindowCommands: Commands {
    @Binding var playEngine: PlayEngine
    @Binding var windowController: WindowController

    var body: some Commands {
        CommandGroup(after: .windowSize) {
            Section {
                Button {
                    PlayEngine.shared.fitToVideoSize()
                } label: {
                    Text(
                        "Natural Size",
                        comment: "Fit window to video size"
                    )
                }
                .keyboardShortcut("0", modifiers: [.command])
                .disabled(!playEngine.isLoaded || windowController.isFullscreen)
            }
        }
    }
}
