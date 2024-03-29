//
//  ViewCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import AVKit
import SwiftUI

struct ViewCommands: Commands {
    @Binding var playEngine: PlayEngine
    @Binding var windowController: WindowController

    var body: some Commands {
        CommandGroup(replacing: .toolbar) {
            Button {
                NSApplication.shared.mainWindow?.toggleFullScreen(nil)
            } label: {
                Text(windowController.isFullscreen ? "Exit Full Screen" : "Enter Full Screen")
            }
            .keyboardShortcut(.return, modifiers: [])

            Toggle(isOn: $windowController.isOnTop) {
                Text("Float on Top")
            }

            Divider()

            subtitlePicker
            audioTrackPicker
        }
    }

    @ViewBuilder private var subtitlePicker: some View {
        if let group = playEngine.subtitleGroup {
            Picker("Subtitle", selection: $playEngine.subtitle) {
                Text("Off").tag(nil as AVMediaSelectionOption?)

                let optionsWithoutForcedSubs = group.options.filter {
                    !$0.displayName.contains("Forced")
                }
                ForEach(optionsWithoutForcedSubs) {
                    option in
                    Text(verbatim: option.displayName).tag(Optional(option))
                }
            }
            .pickerStyle(.inline)
        } else {
            Picker("Subtitle", selection: .constant(0)) {
                Text("None").tag(0)
            }
            .pickerStyle(.inline)
            .disabled(true)
        }
    }

    @ViewBuilder private var audioTrackPicker: some View {
        if let group = playEngine.audioGroup {
            Picker("Audio Track", selection: $playEngine.audioTrack) {
                Text("Off").tag(nil as AVMediaSelectionOption?)
                ForEach(group.options) { option in
                    Text(verbatim: option.displayName).tag(Optional(option))
                }
            }
            .pickerStyle(.inline)
        } else {
            Picker("Audio Track", selection: .constant(0)) {
                Text("None").tag(0)
            }
            .pickerStyle(.inline)
            .disabled(true)
        }
    }
}
