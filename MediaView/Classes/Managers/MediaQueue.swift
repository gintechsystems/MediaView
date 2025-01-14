//
//  MediaQueue.swift
//  Pods
//
//  Created by Andrew Boryk on 6/30/17.
//
//

import Foundation

@objcMembers
public class MediaQueue: NSObject {
    
    /// Shared Manager, which keeps track of mediaViews
    public static let shared = MediaQueue()
    
    /// Media view that is currently presented by the manager
    private(set) public var current: MediaView?
    
    /// Queue which holds an array of mediaViews to be displayed
    private var queue = [MediaView]()
    
    /// Add mediaView to the queue
    public func queue(mediaView: MediaView) {
        queue.append(mediaView)
        
        if queue.count == 1 {
            presentNext()
        }
    }
    
    /// Present the next mediaView in the queue and dismiss the current one
    public func presentNext() {
        if let mediaView = queue.first {
            present(mediaView: mediaView)
        } else if current != nil {
            dismissCurrent()
        } else {
            // No MediaView in queue or currently presented
        }
    }
    
    /// Present the given mediaView
    public func present(mediaView: MediaView, animated: Bool = true) {
        if current != nil {
            dismissCurrent() {
                self.handlePresentation(for: mediaView)
            }
        } else {
            handlePresentation(for: mediaView)
        }
    }
    
    private func handlePresentation(for mediaView: MediaView, animated: Bool = true) {
        dequeue(mediaView: mediaView)
        
        mediaView.prepForPresentation()
        
        UIWindow.main.makeKeyAndVisible()
        UIWindow.main.addSubview(mediaView)
        UIWindow.main.bringSubviewToFront(mediaView)
        
        current = mediaView
        
        var animationTime = mediaView.originRectConverted == nil ? 0.25 : 0.5
        animationTime = animated ? animationTime : 0
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options: .curveLinear, animations: {
            mediaView.alpha = 1
            mediaView.layoutSubviews()
            mediaView.frame = UIWindow.main.frame
            
            if !mediaView.shouldAutoPlayAfterPresentation {
                mediaView.handleTopOverlayDisplay()
            }
            
        }) { _ in
            mediaView.delegate?.didPresent(mediaView: mediaView)
            
            if mediaView.hasPlayableMedia, mediaView.shouldAutoPlayAfterPresentation {
                mediaView.handleTapFromRecognizer()
            }
        }
    }
    
    /// Remove mediaView from the queue
    public func dequeue(mediaView: MediaView) {
        if let index = queue.firstIndex(of: mediaView) {
            queue.remove(at: index)
        }
    }
    
    /// Dismiss the currently presented mediaView
    public func dismissCurrent(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let current = current, current.isFullScreen else {
            completion?()
            return
        }
        
        current.player?.pause()
        current.player = nil
        current.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0.0, options: .curveLinear, animations: {
            switch current.swipeMode {
            case .dismiss:
                current.frame = .offscreenRect
            case .minimize where current.isMinimized:
                var minimizedFrame = current.minimizedFrame
                minimizedFrame.origin.x = UIScreen.superviewWidth
                current.frame = minimizedFrame
            default:
                break
            }
            
            current.alpha = 0
        }) { _ in
            current.resetMedia()
            
            current.delegate?.didDismiss(mediaView: current)
            self.current = nil
            
            completion?()
        }
    }
}
