//
//  AppCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/11/24.
//

import Sparkle
import SwiftUI

struct AppCommands: Commands {
    private let updater: SPUUpdater

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button {
                updater.checkForUpdates()
            } label: {
                Text("Check for Updates…")
            }
            .disabled(!updater.canCheckForUpdates)
        }
    }

    init(updater: SPUUpdater) {
        self.updater = updater
    }
}
