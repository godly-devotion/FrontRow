//
//  GoToTimeView.swift
//  Front Row
//
//  Created by Joshua Park on 3/19/24.
//

import SwiftUI

struct GoToTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timecode = ""

    var body: some View {
        VStack {
            TextField(text: $timecode, prompt: Text(verbatim: "0:00:00")) {}
                .onSubmit {
                    PlayEngine.shared.goToTime(timecode)
                    dismiss()
                }
                .autocorrectionDisabled()
                .lineLimit(1)

            Button("Go") {
                dismiss()
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    GoToTimeView()
}
