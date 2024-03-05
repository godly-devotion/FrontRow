//
//  ContentView.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @Environment(PlayEngine.self) private var playEngine: PlayEngine

    var body: some View {
        VideoPlayer(player: playEngine.player)
            .background(
                VisualEffectView()
                    .ignoresSafeArea()
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
