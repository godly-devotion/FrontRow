//
//  PlaybackCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct PlaybackCommands: Commands {
    @Binding var playEngine: PlayEngine
    @Binding var isPresentingOpenURLView: Bool
    @Binding var isPresentingGoToTimeView: Bool

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
            }
            Section {
                Button {
                    playEngine.goForwards()
                } label: {
                    Text("Go Forward 5s")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(
                    !playEngine.isLoaded || isPresentingOpenURLView || isPresentingGoToTimeView)

                Button {
                    playEngine.goBackwards()
                } label: {
                    Text("Go Backward 5s")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(
                    !playEngine.isLoaded || isPresentingOpenURLView || isPresentingGoToTimeView)

                Button {
                    playEngine.goToTime(0.0)
                } label: {
                    Text("Go to Beginning")
                }
                .disabled(!playEngine.isLoaded)

                Button {
                    isPresentingGoToTimeView = true
                } label: {
                    Text("Go to Time...")
                }
                .keyboardShortcut("J", modifiers: [.command])
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
