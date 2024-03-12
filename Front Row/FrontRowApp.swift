//
//  FrontRowApp.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import Sparkle
import SwiftUI

@main
struct FrontRowApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var playEngine: PlayEngine
    @State private var windowController: WindowController
    private let updaterController: SPUStandardUpdaterController

    init() {
        self._playEngine = .init(wrappedValue: .shared)
        self._windowController = .init(wrappedValue: .shared)

        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        UserDefaults.standard.removeObject(forKey: "NSWindow Frame main")
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }

    var body: some Scene {
        Window("Front Row", id: "main") {
            ContentView()
                .environment(playEngine)
                .onContinuousHover { phase in
                    switch phase {
                    case .active:
                        windowController.resetMouseIdleTimer()
                        windowController.showTitlebar()
                    case .ended:
                        windowController.hideTitlebar()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            AppCommands(updater: updaterController.updater)
            FileCommands()
            ViewCommands(windowController: windowController)
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
