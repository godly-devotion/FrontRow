//
//  PlaybackCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct PlaybackCommands: Commands {
    @Binding var playEngine: PlayEngine
    @Binding var presentedViewManager: PresentedViewManager

    var body: some Commands {
        CommandMenu("Playback") {
            Section {
                Button {
                    playEngine.playPause()
                } label: {
                    Text(
                        playEngine.isPlaying ? "Pause" : "Play",
                        comment: "Toggle playback status"
                    )
                }
                .keyboardShortcut(.space, modifiers: [])
                .disabled(!playEngine.isLoaded)

                Button {
                    Task { await playEngine.goToTime(0.0) }
                } label: {
                    Text(
                        "Restart",
                        comment: "Restart playback from the beginning"
                    )
                }
                .keyboardShortcut(.leftArrow, modifiers: [.command])
                .disabled(!playEngine.isLoaded || presentedViewManager.isPresenting)
            }
            Section {
                Button {
                    Task { await playEngine.goForwards() }
                } label: {
                    Text("Go Forward 5s")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(
                    !playEngine.isLoaded || presentedViewManager.isPresenting)

                Button {
                    Task { await playEngine.goBackwards() }
                } label: {
                    Text("Go Backward 5s")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(
                    !playEngine.isLoaded || presentedViewManager.isPresenting)

                Button {
                    PresentedViewManager.shared.isPresentingGoToTimeView.toggle()
                } label: {
                    Text("Go to Time...")
                }
                .keyboardShortcut("G", modifiers: [.command])
                .disabled(!playEngine.isLoaded)
            }
            Section {
                Toggle(isOn: $playEngine.isMuted) {
                    Text("Mute")
                }
                .keyboardShortcut("M", modifiers: [])
            }
        }
    }
}
