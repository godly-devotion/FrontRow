//
//  ViewCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct ViewCommands: Commands {
    @Binding var windowController: WindowController

    var body: some Commands {
        CommandGroup(replacing: .toolbar) {
            Section {
                Button {
                    NSApplication.shared.mainWindow?.toggleFullScreen(nil)
                } label: {
                    Text(windowController.isFullscreen ? "Exit Full Screen" : "Enter Full Screen")
                }
                .keyboardShortcut(.return, modifiers: [])

                Toggle(isOn: $windowController.isOnTop) {
                    Text("Float on Top")
                }
            }
        }
    }
}
