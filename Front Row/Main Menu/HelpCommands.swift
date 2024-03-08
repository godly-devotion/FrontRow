//
//  HelpCommands.swift
//  Front Row
//
//  Created by Joshua Park on 3/7/24.
//

import SwiftUI

struct HelpCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            Link(
                "Release Notes",
                destination: URL(string: "https://github.com/godly-devotion/FrontRow/releases")!
            )
            Link(
                "Website",
                destination: URL(string: "https://github.com/godly-devotion/FrontRow")!
            )
        }
    }
}
