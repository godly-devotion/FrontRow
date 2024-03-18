//
//  ContentView.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import AVKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VideoPlayer(player: PlayEngine.shared.player)
            .onDrop(
                of: [.mpeg4Movie], isTargeted: nil,
                perform: { providers -> Bool in
                    guard let provider = providers.first else { return false }
                    provider.loadItem(forTypeIdentifier: UTType.mpeg4Movie.identifier, options: nil)
                    { (urlData, _) in
                        guard let url = urlData as? URL else { return }
                        PlayEngine.shared.openFile(url: url)
                    }
                    return true
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
