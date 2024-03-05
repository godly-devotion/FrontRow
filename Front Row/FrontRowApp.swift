//
//  FrontRowApp.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

@main
struct FrontRowApp: App {
    @State private var playEngine: PlayEngine
    
    init() {
        self._playEngine = .init(wrappedValue: .shared)
        UserDefaults.standard.removeObject(forKey: "NSWindow Frame main")
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    var body: some Scene {
        Window("Front Row", id: "main") {
            ContentView()
                .environment(playEngine)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            FileCommands(playEngine: playEngine)
            ViewCommands()
            PlaybackCommands(playEngine: playEngine)
        }
    }
}
