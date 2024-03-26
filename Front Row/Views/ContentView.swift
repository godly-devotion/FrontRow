//
//  ContentView.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var playerControlsShown = true
    @State private var mouseIdleTimer: Timer!

    var body: some View {
        ZStack(alignment: .bottom) {
            PlayerView(player: PlayEngine.shared.player)
                .onDrop(
                    of: [.fileURL],
                    delegate: AnyDropDelegate(
                        onValidate: {
                            $0.hasItemsConforming(to: PlayEngine.supportedFileTypes)
                        },
                        onPerform: {
                            guard let provider = $0.itemProviders(for: [.fileURL]).first else {
                                return false
                            }

                            Task {
                                guard let url = await provider.getURL() else { return }
                                PlayEngine.shared.openFile(url: url)
                            }

                            return true
                        }
                    )
                )
                .onTapGesture(count: 2) {
                    NSApplication.shared.mainWindow?.toggleFullScreen(nil)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()

            if playerControlsShown {
                PlayerControlsView()
                    .animation(.linear(duration: 0.4), value: playerControlsShown)
            }
        }
        .background {
            Color.black.ignoresSafeArea()
        }
        .onContinuousHover { phase in
            switch phase {
            case .active:
                resetMouseIdleTimer()
                showPlayerControls()
                WindowController.shared.resetMouseIdleTimer()
                WindowController.shared.showTitlebar()
            case .ended:
                hidePlayerControls()
                WindowController.shared.hideTitlebar()
            }
        }
    }

    private func resetMouseIdleTimer() {
        if mouseIdleTimer != nil {
            mouseIdleTimer.invalidate()
            mouseIdleTimer = nil
        }

        mouseIdleTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
            mouseIdleTimerAction($0)
        }
    }

    private func hidePlayerControls() {
        withAnimation {
            playerControlsShown = false
        }
    }

    private func showPlayerControls() {
        withAnimation {
            playerControlsShown = true
        }
    }

    private func mouseIdleTimerAction(_ sender: Timer) {
        hidePlayerControls()
    }
}

#Preview {
    ContentView()
}
