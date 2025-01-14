//
//  MediaView+Delegates.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import Foundation
import AVFoundation

@objc
extension MediaView: UIGestureRecognizerDelegate, LabelDelegate, TrackViewDelegate, PlayerDelegate, PlayIndicatorDelegate {
    
    // MARK: - LabelDelegate
    func didTouchUpInside(label: Label) {
        switch label.tag {
        case 1000:
            delegate?.handleTitleSelection(in: self)
        case 2000:
            delegate?.handleDetailsSelection(in: self)
        default:
            break
        }
    }
    
    // MARK: - TrackViewDelegate
    func seekTo(time: TimeInterval, track: TrackView) {
        guard let player = player, let timeScale = player.currentItem?.asset.duration.timescale else {
            return
        }
        
        let timeCM = CMTimeMakeWithSeconds(time, preferredTimescale: timeScale)
        player.seek(to: timeCM, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    // MARK: - PlayIndicatorDelegate
    func shouldShowPlayIndicator() -> Bool {
        return hasPlayableMedia && isLoadingVideo
    }
    
    func image(for playIndicatorView: PlayIndicatorView) -> UIImage? {
        if shouldHidePlayButton {
            return nil
        } else if let player = player, player.didFailToPlay {
            return customFailButton ?? UIImage.failIndicator(themeColor: themeColor)
        } else if let playButton = customPlayButton, hasVideo {
            return playButton
        } else if let musicButton = customMusicButton, hasAudio {
            return musicButton
        } else {
            return .playIndicator(themeColor: themeColor, isFullScreen: isFullScreen, pressShowsGIF: pressShowsGIF)
        }
    }
    
    func player(for playIndicatorView: PlayIndicatorView) -> Player? {
        return player
    }
    
    // MARK: - PlayerDelegate
    func didPlay(player: Player) {
        handleTopOverlayDisplay()
        
        if !player.didFailToPlay {
            delegate?.didPlayMedia(for: self)
        }
    }
    
    func didPause(player: Player) {
        playIndicatorView.endAnimation()
        setPlayIndicatorView()
        handleTopOverlayDisplay()
        
        delegate?.didPauseMedia(for: self)
    }
    
    func didFail(player: Player) {
        player.pause()
        delegate?.didFailToPlayMedia(for: self)
    }
    
    func didBecomeReadyToPlay(player: Player) {
        setPlayIndicatorView(alpha: 0)
    }
    
    func didProgress(to time: TimeInterval, item: AVPlayerItem) {
        resetImageIfVideo()
        
        if time != 0 && playIndicatorView.animateTimer.isValid {
            playIndicatorView.endAnimation()
            hidePlayIndicator()
        }
        
        track.setProgress(time, duration: TimeInterval(CMTimeGetSeconds(item.duration)))
    }
    
    func didBuffer(to time: TimeInterval, item: AVPlayerItem) {
        track.setBuffer(time, duration: TimeInterval(CMTimeGetSeconds(item.duration)))
    }
    
    func bufferDidBecomeEmpty(for player: Player) {
        // TODO: Find something useful to be done here
    }
    
    func playbackLikelyToKeepUp(for player: Player) {
        resetImageIfVideo()
    }
    
    func bufferDidBecomeNotEmpty(for player: Player) {
        resetImageIfVideo()
    }
    
    func cacheMedia(for asset: AVAsset) {
        if let videoURL = media.videoURL {
            CacheManager.cache(url: videoURL, cache: .video, asset: asset)
        } else if let audioURL = media.audioURL {
            CacheManager.cache(url: audioURL, cache: .audio, asset: asset)
        }
    }
    
    private func resetImageIfVideo() {
        if hasVideo, let playerLayer = layer as? AVPlayerLayer, playerLayer.isReadyForDisplay {
            image = nil
        }
    }
}
