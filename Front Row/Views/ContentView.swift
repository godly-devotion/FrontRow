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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
