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
        .wav,
    ]

    private var asset: AVAsset?

    private(set) var player = AVPlayer()

    private(set) var isLoaded = false

    private(set) var timeControlStatus: AVPlayer.TimeControlStatus = .paused

    private(set) var isLocalFile = false

    private var _currentTime: TimeInterval = 0.0

    var currentTime: Double {
        get {
            access(keyPath: \.currentTime)
            return _currentTime
        }
        set {
            withMutation(keyPath: \.currentTime) {
                let time = CMTimeMakeWithSeconds(newValue, preferredTimescale: 1)
                player.seek(to: time)
            }
        }
    }

    private(set) var duration: TimeInterval = 0.0

    private(set) var timeRemaining: TimeInterval = 0.0

    var playbackSpeed: Float {
        get {
            access(keyPath: \.playbackSpeed)
            return player.defaultRate
        }
        set {
            withMutation(keyPath: \.playbackSpeed) {
                if Float.isApproxEqual(lhs: newValue, rhs: 1.0) {
                    player.rate = 1.0
                    player.defaultRate = 1.0
                    return
                }

                if newValue > player.defaultRate {
                    let newSpeed = min(newValue, 2.0)
                    player.rate = newSpeed
                    player.defaultRate = newSpeed
                } else if newValue < player.defaultRate {
                    let newSpeed = max(newValue, 0.05)
                    player.rate = newSpeed
                    player.defaultRate = newSpeed
                } else {
                    player.rate = newValue
                    player.defaultRate = newValue
                }
            }
        }
    }

    private var _isMuted = false

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

    private(set) var subtitleGroup: AVMediaSelectionGroup?

    var subtitle: AVMediaSelectionOption? {
        didSet {
            guard let subtitleGroup else { return }
            selectTrack(subtitle, in: subtitleGroup)
        }
    }

    private(set) var audioGroup: AVMediaSelectionGroup?

    var audioTrack: AVMediaSelectionOption? {
        didSet {
            guard let audioGroup else { return }
            selectTrack(audioTrack, in: audioGroup)
        }
    }

    private var videoSize = CGSize.zero

    private var subs = Set<AnyCancellable>()

    private var currentItemSubs = Set<AnyCancellable>()

    private var timeObserver: Any?

    init() {
        player.preventsDisplaySleepDuringVideoPlayback = true
        player.appliesMediaSelectionCriteriaAutomatically = false

        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                self.timeControlStatus = status
            }
            .store(in: &subs)

        player.publisher(for: \.isMuted)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isMuted in
                self._isMuted = isMuted
            }
            .store(in: &subs)

        addPeriodicTimeObserver()
    }

    deinit {
        for sub in currentItemSubs { sub.cancel() }
        currentItemSubs.removeAll()
        removePeriodicTimeObserver()
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
        await openFile(url: url)
    }

    /// Attempts to open file at url. If its not playable, returns false.
    /// - Parameter url: A URL to a local, remote, or HTTP Live Streaming media resource.
    /// - Returns: A Boolean value that indicates whether an asset contains playable content.
    @MainActor
    @discardableResult func openFile(url: URL) async -> Bool {
        if asset != nil {
            asset!.cancelLoading()
        }
        asset = AVAsset(url: url)
        do {
            let isPlayable = try await asset!.load(.isPlayable)
            guard isPlayable else { return false }

            if let subtitleGroup = try await asset!.loadMediaSelectionGroup(for: .legible) {
                self.subtitleGroup = subtitleGroup
            } else {
                self.subtitleGroup = nil
            }

            if let audioGroup = try await asset!.loadMediaSelectionGroup(for: .audible) {
                self.audioGroup = audioGroup
            } else {
                self.audioGroup = nil
            }
        } catch {
            return false
        }

        for sub in currentItemSubs { sub.cancel() }
        currentItemSubs.removeAll()

        let playerItem = AVPlayerItem(asset: asset!)

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
                videoSize = size
                fitToVideoSize()
            }
            .store(in: &currentItemSubs)

        player.replaceCurrentItem(with: playerItem)
        player.play()

        if let subtitleGroup {
            subtitle = subtitleGroup.options.first
        } else {
            subtitle = nil
        }

        if let audioGroup {
            audioTrack = audioGroup.options.first
        } else {
            audioTrack = nil
        }

        return true
    }

    func cancelLoading() {
        guard let asset else { return }

        asset.cancelLoading()
    }

    func play() {
        guard isLoaded else { return }

        player.play()
    }

    func pause() {
        guard isLoaded else { return }

        player.pause()
    }

    func playPause() {
        guard isLoaded else { return }

        if timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }

    func goForwards(_ duration: Double = 5.0) async {
        guard isLoaded else { return }

        let time = CMTimeAdd(
            player.currentTime(),
            CMTimeMakeWithSeconds(duration, preferredTimescale: 1)
        )
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func goBackwards(_ duration: Double = 5.0) async {
        guard isLoaded else { return }

        let time = CMTimeSubtract(
            player.currentTime(),
            CMTimeMakeWithSeconds(duration, preferredTimescale: 1)
        )
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func goToTime(_ timecode: Double) async {
        guard isLoaded else { return }

        let time = CMTimeMakeWithSeconds(timecode, preferredTimescale: 1)
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func goToTime(_ timecode: String) async {
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

        let validRange = CMTimeRange(start: .zero, end: item.duration)
        guard validRange.containsTime(time) else { return }
        await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func fitToVideoSize() {
        guard let window = NSApp.windows.first else { return }
        guard videoSize != CGSize.zero else {
            /// reset aspect ratio setting
            window.resizeIncrements = NSMakeSize(1.0, 1.0)
            return
        }

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

    private func selectTrack(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup) {
        guard let item = player.currentItem else { return }
        item.select(option, in: group)
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            _currentTime = time.seconds

            guard let duration = player.currentItem?.duration.seconds else { return }
            guard !duration.isNaN && !duration.isInfinite else { return }
            self.duration = duration
            timeRemaining = duration - _currentTime
        }
    }

    private func removePeriodicTimeObserver() {
        guard let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }
}
