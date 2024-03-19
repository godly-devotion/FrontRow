//
//  PlayEngine.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import AVKit
import SwiftUI

@Observable public final class PlayEngine {

    static let shared = PlayEngine()

    var player = AVPlayer()

    var isLoaded = false

    var isPlaying = false

    var isLocalFile = false

    var isMuted: Bool {
        get {
            access(keyPath: \.isMuted)
            return _isMuted
        }
        set {
            withMutation(keyPath: \.isMuted) {
                _isMuted = newValue
                player.isMuted = newValue
            }
        }
    }

    private var _isMuted = false

    private var aspect = CGSize.zero

    private var sizeObserver: NSKeyValueObservation?

    private var rateObserver: NSKeyValueObservation?

    private var muteObserver: NSKeyValueObservation?

    init() {
        player.preventsDisplaySleepDuringVideoPlayback = true

        rateObserver = player.observe(\.rate, options: .new) { player, change in
            guard let value = change.newValue else {
                self.isPlaying = false
                return
            }
            self.isPlaying = !value.isZero
        }

        muteObserver = player.observe(\.isMuted, options: .new) { player, change in
            guard let value = change.newValue else { return }
            self._isMuted = value
        }
    }

    func isURLPlayable(url: URL) async -> Bool {
        let asset = AVAsset(url: url)
        do {
            return try await asset.load(.isPlayable)
        } catch {
            return false
        }
    }

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

        sizeObserver = player.observe(\.currentItem?.presentationSize, options: .new) {
            player, change in
            guard let value = change.newValue, let aspect = value else { return }
            guard aspect != CGSize.zero else { return }
            self.aspect = aspect
            self.fitToVideoSize()
        }

        player.play()
        isLoaded = true
        isLocalFile = FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }

    func playPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func stepForwards(_ duration: Double = 5.0) {
        if !isLoaded {
            return
        }

        let time = CMTimeAdd(
            player.currentTime(), CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
        if CMTIME_IS_INVALID(time) {
            return
        }
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func stepBackwards(_ duration: Double = 5.0) {
        if !isLoaded {
            return
        }

        let time = CMTimeSubtract(
            player.currentTime(), CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
        if CMTIME_IS_INVALID(time) {
            return
        }
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func fitToVideoSize() {
        if !isLoaded || aspect == CGSize.zero {
            return
        }

        guard let window = NSApp.windows.first else { return }
        let screenFrame = (window.screen ?? NSScreen.main!).visibleFrame
        let newFrame: NSRect

        if aspect.width < screenFrame.width && aspect.height < screenFrame.height {
            let newOrigin = CGPoint(
                x: screenFrame.origin.x + (screenFrame.width - aspect.width) / 2,
                y: screenFrame.origin.y + (screenFrame.height - aspect.height) / 2
            )
            newFrame = NSRect(origin: newOrigin, size: aspect)
        } else {
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
