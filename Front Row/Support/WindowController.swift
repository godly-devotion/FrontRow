//
//  WindowController.swift
//  Front Row
//
//  Created by Joshua Park on 3/11/24.
//

import SwiftUI

@Observable public final class WindowController {

    static let shared = WindowController()

    private var _isOnTop = false

    var isOnTop: Bool {
        get {
            access(keyPath: \.isOnTop)
            return _isOnTop
        }
        set {
            withMutation(keyPath: \.isOnTop) {
                _isOnTop = newValue
                NSApplication.shared.mainWindow?.level = _isOnTop ? .floating : .normal
            }
        }
    }

    private var _titlebarView: NSView?

    var titlebarView: NSView? {
        guard _titlebarView == nil else { return _titlebarView }

        guard let containerClass = NSClassFromString("NSTitlebarContainerView") else { return nil }
        guard
            let containerView = NSApp.windows.first?.contentView?.superview?.subviews.reversed()
                .first(where: { $0.isKind(of: containerClass) })
        else { return nil }

        _titlebarView = containerView

        return _titlebarView
    }

    private var mouseIdleTimer: Timer!

    func resetMouseIdleTimer() {
        if mouseIdleTimer != nil {
            mouseIdleTimer.invalidate()
            mouseIdleTimer = nil
        }

        mouseIdleTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
            [weak self] in
            self?.mouseIdleTimerAction($0)
        }
    }

    func hideTitlebar() {
        setTitlebarOpacity(0.0)
    }

    func showTitlebar() {
        setTitlebarOpacity(1.0)
    }

    private func mouseIdleTimerAction(_ sender: Timer) {
        hideTitlebar()
    }

    private func setTitlebarOpacity(_ opacity: CGFloat) {
        /// when the window is in full screen, the titlebar view is in another window (the "toolbar window")
        guard titlebarView?.window == NSApp.windows.first else { return }

        NSAnimationContext.runAnimationGroup(
            { ctx in
                ctx.duration = 0.4
                self.titlebarView?.animator().alphaValue = opacity
            }, completionHandler: nil)
    }
}
