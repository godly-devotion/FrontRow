//
//  Extensions.swift
//  Front Row
//
//  Created by Joshua Park on 3/4/24.
//

import AVKit
import Foundation
import SwiftUI

struct AnyDropDelegate: DropDelegate {
    var isTargeted: Binding<Bool>?
    var onValidate: ((DropInfo) -> Bool)?
    let onPerform: (DropInfo) -> Bool
    var onEntered: ((DropInfo) -> Void)?
    var onExited: ((DropInfo) -> Void)?
    var onUpdated: ((DropInfo) -> DropProposal?)?

    func performDrop(info: DropInfo) -> Bool {
        onPerform(info)
    }

    func validateDrop(info: DropInfo) -> Bool {
        onValidate?(info) ?? true
    }

    func dropEntered(info: DropInfo) {
        isTargeted?.wrappedValue = true
        onEntered?(info)
    }

    func dropExited(info: DropInfo) {
        isTargeted?.wrappedValue = false
        onExited?(info)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        onUpdated?(info)
    }
}

extension NSItemProvider: @unchecked Sendable {}

extension NSItemProvider {
    func loadObject<T>(ofClass: T.Type) async throws -> T? where T: NSItemProviderReading {
        try await withCheckedThrowingContinuation { continuation in
            _ = loadObject(ofClass: ofClass) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let object = data as? T else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: object)
            }
        }
    }

    func loadObject<T>(ofClass: T.Type) async throws -> T?
    where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        try await withCheckedThrowingContinuation { continuation in
            _ = loadObject(ofClass: ofClass) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let data else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: data)
            }
        }
    }

    /// Get a URL from the item provider, if any.
    func getURL() async -> URL? {
        try? await loadObject(ofClass: URL.self)
    }
}

extension NSSize {
    var aspect: CGFloat {
        assert(width != 0 && height != 0)
        return width / height
    }

    /// Given another size S, returns a size that:

    /// - maintains the same aspect ratio;
    /// - has same height or/and width as S;
    /// - always smaller than S.

    /// - parameter toSize: The given size S.

    /// ```
    /// +--+------+--+
    /// |  |The   |  |
    /// |  |result|  |<-- S
    /// |  |size  |  |
    /// +--+------+--+
    /// ```
    func shrink(toSize size: NSSize) -> NSSize {
        if width == 0 || height == 0 {
            return size
        }
        let sizeAspect = size.aspect
        if aspect < sizeAspect {  // self is taller, shrink to meet height
            return NSSize(width: size.height * aspect, height: size.height)
        } else {
            return NSSize(width: size.width, height: size.width / aspect)
        }
    }
}

extension TimeInterval {
    /// Returns value as timecode string.
    /// - Parameter longestTime: Used to determine if hour should be displayed
    /// - Returns: 0:00 or 0:00:00
    ///
    func asTimecode(using longestTime: TimeInterval) -> String {
        let hasHour = (longestTime / 3600.0) > 1.0
        if hasHour {
            return Duration.seconds(self).formatted(
                .time(pattern: .hourMinuteSecond(padHourToLength: 0)))
        } else {
            return Duration.seconds(self).formatted(
                .time(pattern: .minuteSecond(padMinuteToLength: 2)))
        }
    }
}

extension AVMediaSelectionOption: Identifiable {
    public var id: String {
        let dict = propertyList() as? NSDictionary
        guard let dict, let id = dict.value(forKey: "MediaSelectionOptionsPersistentID") as? Int
        else {
            return displayName
        }
        guard
            let nonforcedSubtitles = dict.value(
                forKey: "MediaSelectionOptionsDisplaysNonForcedSubtitles") as? Int
        else {
            return "\(id)"
        }
        return "\(id)\(nonforcedSubtitles)"
    }
}
