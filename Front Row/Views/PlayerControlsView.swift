//
//  PlayerControlsView.swift
//  Front Row
//
//  Created by Joshua Park on 3/25/24.
//

import SwiftUI

struct PlayerControlsView: View {
    @Environment(PlayEngine.self) private var playEngine: PlayEngine
    private let foregroundColor = Color.white.opacity(0.8)

    var body: some View {
        @Bindable var playEngine = playEngine

        HStack(spacing: 16) {
            // MARK: Backwards
            Button {
                Task { await PlayEngine.shared.goBackwards() }
            } label: {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .frame(height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut("J", modifiers: [])
            .disabled(!playEngine.isLoaded)

            // MARK: Pause/Play
            Button {
                PlayEngine.shared.playPause()
            } label: {
                Image(
                    systemName: playEngine.timeControlStatus == .playing
                        ? "pause.fill"
                        : "play.fill"
                )
                .resizable()
                .scaledToFit()
                .foregroundStyle(foregroundColor)
                .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut("K", modifiers: [])
            .disabled(!playEngine.isLoaded)

            // MARK: Forwards
            Button {
                Task { await PlayEngine.shared.goForwards() }
            } label: {
                Image(systemName: "goforward.5")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .frame(height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut("L", modifiers: [])
            .disabled(!playEngine.isLoaded)

            // MARK: Current time
            Text(verbatim: playEngine.currentTime.asTimecode)
                .font(.system(size: 11))
                .foregroundStyle(foregroundColor)
                .frame(width: 50, alignment: .center)

            // MARK: Seek slider
            SeekSliderView(value: $playEngine.currentTime, maxValue: playEngine.duration)
                .disabled(!playEngine.isLoaded)

            // MARK: Time remaining
            Text(verbatim: playEngine.duration.asTimecode)
                .font(.system(size: 11))
                .foregroundStyle(foregroundColor)
                .frame(width: 50, alignment: .center)
        }
        .padding([.horizontal], 16)
        .padding([.vertical], 8)
        .background(.ultraThickMaterial)
    }
}

#Preview {
    PlayerControlsView()
}
