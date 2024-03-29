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
    @State private var presentedViewManager: PresentedViewManager
    @State private var windowController: WindowController

    init() {
        self._playEngine = .init(wrappedValue: .shared)
        self._presentedViewManager = .init(wrappedValue: .shared)
        self._windowController = .init(wrappedValue: .shared)

        UserDefaults.standard.removeObject(forKey: "NSWindow Frame main")
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }

    var body: some Scene {
        Window("Front Row", id: "main") {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(playEngine)
                .sheet(isPresented: $presentedViewManager.isPresentingOpenURLView) {
                    OpenURLView()
                        .frame(minWidth: 600)
                }
                .alert("Go to Time", isPresented: $presentedViewManager.isPresentingGoToTimeView) {
                    GoToTimeView()
                } message: {
                    Text("Enter the time you want to go to")
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: NSWindow.didEnterFullScreenNotification)
                ) { _ in
                    windowController.setIsFullscreen(true)
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: NSWindow.didExitFullScreenNotification)
                ) { _ in
                    windowController.setIsFullscreen(false)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            AppCommands()
            FileCommands(playEngine: $playEngine)
            ViewCommands(
                playEngine: $playEngine,
                windowController: $windowController)
            PlaybackCommands(
                playEngine: $playEngine,
                presentedViewManager: $presentedViewManager)
            WindowCommands(
                playEngine: $playEngine,
                windowController: $windowController)
            HelpCommands()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.count == 1, let url = urls.first else { return }
        Task {
            await PlayEngine.shared.openFile(url: url)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.isMovableByWindowBackground = true
        }
    }
}
