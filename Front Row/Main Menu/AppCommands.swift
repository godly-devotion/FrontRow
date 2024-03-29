//
//  AppCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/11/24.
//

import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Section {
                Button {
                    Task {
                        guard
                            let url = URL(
                                string:
                                    "https://media.developer.dolby.com/DDP/MP4_HPL40_30fps_channel_id_51.mp4"
                            )
                        else { return }
                        await PlayEngine.shared.openFile(url: url)
                    }
                } label: {
                    Text("Experience Spatial Audio")
                }
            }
        }
    }
}
