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
    @State private var displayLoading = false
    @State private var displayError = false

    var body: some View {
        HStack(spacing: 14) {
            if displayLoading {
                ProgressView()
                    .controlSize(.small)
            }

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
                PlayEngine.shared.cancelLoading()
                withAnimation {
                    displayLoading = false
                    displayError = false
                }
            }
            .onSubmit {
                Task {
                    guard let url = URL(string: url) else {
                        withAnimation {
                            displayLoading = false
                            displayError = true
                        }
                        return
                    }
                    displayLoading = true
                    guard await PlayEngine.shared.openFile(url: url) else {
                        withAnimation {
                            displayLoading = false
                            displayError = true
                        }
                        return
                    }
                    withAnimation {
                        displayLoading = false
                        displayError = false
                    }
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
