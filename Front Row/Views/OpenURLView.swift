//
//  OpenURLView.swift
//  Front Row
//
//  Created by Joshua Park on 3/17/24.
//

import SwiftUI

struct OpenURLView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""
    @State private var displayError = false

    var body: some View {
        HStack(spacing: 8) {
            if displayError {
                Image(systemName: "play.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
            }

            TextField(
                text: $url,
                prompt: Text(
                    "Enter URL",
                    comment: "Prompt text for Open URL sheet text field"
                )
            ) {}
            .onChange(of: url) {
                withAnimation {
                    displayError = false
                }
            }
            .onSubmit {
                Task {
                    guard let url = URL(string: url) else {
                        withAnimation {
                            displayError = true
                        }
                        return
                    }
                    if await !PlayEngine.shared.isURLPlayable(url: url) {
                        withAnimation {
                            displayError = true
                        }
                        return
                    }
                    withAnimation {
                        displayError = false
                    }
                    PlayEngine.shared.openFile(url: url)
                    dismiss()
                }
            }
            .autocorrectionDisabled()
            .lineLimit(1)
            .font(.title)
            .textFieldStyle(.plain)
        }
        .padding([.horizontal], 16)
        .padding([.vertical], 12)
    }
}

#Preview {
    OpenURLView()
}
