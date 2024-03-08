//
//  PlaybackCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI

struct PlaybackCommands: Commands {
    var playEngine: PlayEngine

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
                    playEngine.stepForwards()
                } label: {
                    Text("Step Forward 5s")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(!playEngine.isLoaded)

                Button {
                    playEngine.stepBackwards()
                } label: {
                    Text("Step Backward 5s")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(!playEngine.isLoaded)
            }
            Section {
                Button {
                    playEngine.toggleMute()
                } label: {
                    if playEngine.isMuted {
                        Image(systemName: "checkmark")
                    }
                    Text("Mute")
                }
                .keyboardShortcut("M", modifiers: [])
            }
        }
    }
}
