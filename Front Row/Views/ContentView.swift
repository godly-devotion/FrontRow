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
            .onDrop(of: [.mpeg4Movie], isTargeted: nil, perform: { providers -> Bool in
                guard let provider = providers.first else { return false }
                provider.loadItem(forTypeIdentifier: UTType.mpeg4Movie.identifier, options: nil) { (urlData, _) in
                    guard let url = urlData as? URL else { return }
                    playEngine.openFile(url: url)
                }
                return true
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
