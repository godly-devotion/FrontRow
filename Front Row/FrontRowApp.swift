//
//  FrontRowApp.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

@main
struct FrontRowApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
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
        .commands {
            FileCommands()
            ViewCommands()
            PlaybackCommands(playEngine: playEngine)
            HelpCommands()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.count == 1, let url = urls.first else { return }
        PlayEngine.shared.openFile(url: url)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.isMovableByWindowBackground = true
        }
    }
}
