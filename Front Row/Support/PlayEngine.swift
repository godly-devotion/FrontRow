//
//  PlayEngine.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import AVKit
import Combine
import SwiftUI

@Observable public final class PlayEngine {

    static let shared = PlayEngine()

    static let supportedFileTypes: [UTType] = [
        .mp3,
        .mpeg2TransportStream,
        .mpeg4Audio,
        .mpeg4Movie,
        .quickTimeMovie,
    ]

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

    private var videoSize = CGSize.zero

    private var subs = Set<AnyCancellable>()

    private var currentItemSubs = Set<AnyCancellable>()

    init() {
        player.preventsDisplaySleepDuringVideoPlayback = true

        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .map { $0 == AVPlayer.TimeControlStatus.playing }
            .sink { isPlaying in
                self.isPlaying = isPlaying
            }
            .store(in: &subs)

        player.publisher(for: \.isMuted)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isMuted in
                self.isMuted = isMuted
            }
            .store(in: &subs)
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
        panel.allowedContentTypes = PlayEngine.supportedFileTypes
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
        for sub in currentItemSubs { sub.cancel() }
        currentItemSubs = []

        let playerItem = AVPlayerItem(url: url)

        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    isLoaded = true
                    isLocalFile = FileManager.default.fileExists(
                        atPath: url.path(percentEncoded: false))
                case .failed:
                    isLoaded = false
                    isLocalFile = false
                default:
                    break
                }
            }
            .store(in: &currentItemSubs)

        playerItem.publisher(for: \.presentationSize)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                guard let self else { return }
                guard size != CGSize.zero else { return }
                videoSize = size
                fitToVideoSize()
            }
            .store(in: &currentItemSubs)

        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    func playPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func goForwards(_ duration: Double = 5.0) {
        guard isLoaded else { return }
        let time = CMTimeAdd(
            player.currentTime(),
            CMTimeMakeWithSeconds(duration, preferredTimescale: 1)
        )
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func goBackwards(_ duration: Double = 5.0) {
        guard isLoaded else { return }
        let time = CMTimeSubtract(
            player.currentTime(),
            CMTimeMakeWithSeconds(duration, preferredTimescale: 1)
        )
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func goToTime(_ timecode: Double) {
        guard isLoaded else { return }
        let time = CMTimeMakeWithSeconds(timecode, preferredTimescale: 1)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func goToTime(_ timecode: String) {
        guard let item = player.currentItem else { return }

        let split = Array(timecode.split(separator: ":").reversed())

        let _hour: Int? = split.count > 2 ? Int(split[2]) : nil
        let _minute: Int? = split.count > 1 ? Int(split[1]) : nil
        let _second: Double? = !split.isEmpty ? Double(split[0]) : nil

        if _hour == nil && _minute == nil && _second == nil {
            return
        }

        let hour = _hour ?? 0
        let minute = _minute ?? 0
        let second = _second ?? 0.0
        let time = CMTimeMakeWithSeconds(
            Double(hour * 3600 + minute * 60) + second, preferredTimescale: 1)

        let validRange = CMTimeRange(start: CMTime.zero, end: item.duration)
        guard validRange.containsTime(time) else { return }
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func fitToVideoSize() {
        guard videoSize != CGSize.zero else { return }
        guard let window = NSApp.windows.first else { return }
        let screenFrame = (window.screen ?? NSScreen.main!).visibleFrame
        let newFrame: NSRect

        if videoSize.width < screenFrame.width && videoSize.height < screenFrame.height {
            let newOrigin = CGPoint(
                x: screenFrame.origin.x + (screenFrame.width - videoSize.width) / 2,
                y: screenFrame.origin.y + (screenFrame.height - videoSize.height) / 2
            )
            newFrame = NSRect(origin: newOrigin, size: videoSize)
        } else {
            let newSize = videoSize.shrink(toSize: screenFrame.size)
            let newOrigin = CGPoint(
                x: screenFrame.origin.x + (screenFrame.width - newSize.width) / 2,
                y: screenFrame.origin.y + (screenFrame.height - newSize.height) / 2
            )
            newFrame = NSRect(origin: newOrigin, size: newSize)
        }
        window.setFrame(newFrame, display: true, animate: true)
        window.aspectRatio = videoSize
    }
}
