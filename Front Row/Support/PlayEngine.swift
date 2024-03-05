//
//  PlayEngine.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import SwiftUI
import AVKit

@Observable public final class PlayEngine {

    static let shared = PlayEngine()

    var player = AVPlayer()

    var isLoaded = false

    var isPlaying = false

    private var sizeObserver: NSKeyValueObservation?

    private var rateObserver: NSKeyValueObservation?

    @MainActor
    func showOpenFileDialog() async {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.mpeg4Movie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        let resp = await panel.beginSheetModal(for: NSApplication.shared.mainWindow!)
        if resp != .OK {
            return
        }

        guard let url = panel.url else { return }
        openFile(url: url)
    }

    func openFile(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))

        sizeObserver = player.observe(\.currentItem?.presentationSize, options: .new) { player, change in
            guard let value = change.newValue else { return }
            if let aspect = value, aspect != NSSize.zero {
                guard let window = NSApp.windows.first else { return }
                let screenFrame = (window.screen ?? NSScreen.main!).visibleFrame
                let newFrame: NSRect

                if aspect.width < screenFrame.width && aspect.height < screenFrame.height {
                    let newOrigin = CGPoint(
                        x: screenFrame.origin.x + (screenFrame.width - aspect.width) / 2,
                        y: screenFrame.origin.y + (screenFrame.height - aspect.height) / 2
                    )
                    newFrame = NSRect(origin: newOrigin, size: aspect)
                }
                else {
                    let newSize = aspect.shrink(toSize: screenFrame.size)
                    let newOrigin = CGPoint(
                        x: screenFrame.origin.x + (screenFrame.width - newSize.width) / 2,
                        y: screenFrame.origin.y + (screenFrame.height - newSize.height) / 2
                    )
                    newFrame = NSRect(origin: newOrigin, size: newSize)
                }
                window.setFrame(newFrame, display: true, animate: true)
                window.aspectRatio = aspect
            }
        }

        rateObserver = player.observe(\.rate, options: .new) { player, change in
            guard let value = change.newValue else {
                self.isPlaying = false
                return
            }
            self.isPlaying = value != 0.0
        }

        player.play()
        isLoaded = true
    }

    func playPause() {
        if isPlaying {
            player.pause()
        }
        else {
            player.play()
        }
    }

    func stepForwards(_ duration: Double = 5.0) {
        if !isLoaded {
            return
        }

        let time = CMTimeAdd(player.currentTime(), CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
        if CMTIME_IS_INVALID(time) {
            return;
        }
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func stepBackwards(_ duration: Double = 5.0) {
        if !isLoaded {
            return
        }

        let time = CMTimeSubtract(player.currentTime(), CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
        if CMTIME_IS_INVALID(time) {
            return;
        }
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}