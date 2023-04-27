//
//  PlayerView.swift
//  TestLandscapePortarit
//
//  Created by Chen Xiao on 2022/10/25.
//

import UIKit
import AVFoundation
import Alamofire
import mamba

let SCHEMA = "watch"

///https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8
class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    func bind(with player: AVPlayer) {
        playerLayer.player = player
    }
    
    deinit {
        print("player view is freed")
    }
}

class Player: NSObject, ObservableObject {
    var playerItem: AVPlayerItem?
    var preloadType: PreloadType
    
    var notificationToken: NSObjectProtocol?
    var contentUrl: URL?
    
    var playlistParser: PlaylistParser?

    @Published var player: AVPlayer?
    
    var alternativePlayer: AVPlayer?
    var alternativePlayerItem: AVPlayerItem?
    
    init(preloadType: PreloadType) {
        self.preloadType = preloadType
        playlistParser = PlaylistParser()
        super.init()
        notificationToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            // up next
            
            guard var str = self?.contentUrl?.absoluteString else {
                return
            }

            switch self?.preloadType {
                
            case let .some(type):
                if type == .manifest {
                    str = SCHEMA + str
                    self?.play(with: URL(string: str)!)
                } else if type == .multiplePlayers {
                    self?.player = self?.alternativePlayer
                    self?.player?.currentItem?.preferredForwardBufferDuration = 0
                    self?.playerItem?.removeObserver(self!, forKeyPath: #keyPath(AVPlayerItem.status))
                    self?.playerItem = self?.alternativePlayerItem
                    self?.addKVOLister(to: self?.playerItem)
//                    self?.player?.automaticallyWaitsToMinimizeStalling = false
                    self?.player?.play()
                } else if type == .unknown {
                    guard let url = self?.contentUrl else {
                        return
                    }
                    self?.play(with: URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!)
                }
            default:
                return
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var playerItemContext = 0
    
    /// How to solve Call to main actor-isolated instance method 'play(with:)' in a synchronous nonisolated context; this is an error in Swift 6
    /*@MainActor */func play(with url: URL) {
        Task {
            if let player = await setupAsset(url),
               let item = player.currentItem {
                
                DispatchQueue.main.async {
                    self.player = player
                    self.playerItem = item

                    self.addKVOLister(to: self.playerItem)
                }
                    
            }
        }
    }
    
    private func addKVOLister(to playerItem: AVPlayerItem?) {
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
    }
    
    func seekToTheEnd() {
        var duration: Float64 = 0
        if let seekableRange = playerItem?.seekableTimeRanges.last?.timeRangeValue, CMTIMERANGE_IS_VALID(seekableRange) {
                let dur = CMTimeGetSeconds(seekableRange.duration)
                if dur.isNaN == false, dur.isInfinite == false {
                    duration = dur
                }
            let ts = CMTimeMakeWithSeconds(duration * 0.95, preferredTimescale: 100_000)
            playerItem?.seek(to: ts, completionHandler: nil)
        } else {
            print("Failed to seek end")
        }
    }

    func preloadManifest(url: URL?) {
        preloadManifest(url: url, stopped: false)
    }
    
    func stopPlayback() {
        player?.pause()
    }
    
    func preloadInParallel(url: URL?) {
        guard let url else {
            print("preload in parallel failed due to empty url")
            return
        }
        Task(priority: .background) {
            if let player = await setupAsset(url) {
                alternativePlayer = player
                player.currentItem?.preferredForwardBufferDuration = 4
                alternativePlayerItem = player.currentItem
//                player.automaticallyWaitsToMinimizeStalling = true
            }
        }
    }
    
    private func setupAsset(_ url: URL) async -> AVPlayer? {
        contentUrl = url
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self, queue: .main)
        do {
            let _ = try await asset.load(.isPlayable)
            let status = asset.status(of: .isPlayable)
            switch status {
            case .loaded:
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: playerItem)
                return player
            case let .failed(error):
                print(".failed-\(error)")
            case .notYetLoaded:
                print("not yet loaded")
            default:
                break
            }
            return nil
        } catch {
            print("load asset catched \(error)")
            return nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
            
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player?.play()
                DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in
                    if self?.player?.timeControlStatus == .playing {
                        // Player is playing
                        print("playing")
                    } else {
                        // Player is not playing
                        print("not playing")
                    }
                }
            case .failed:
                print(".failed\n\(playerItem?.error)\n\(playerItem?.errorLog())")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
    }
    
    deinit {
        print("player freed")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Preload
extension Player {
    func preloadManifest(url: URL?, stopped: Bool = false) {
        guard let url else {
            print("preload manifest failed empty url")
            return
        }
        AF.request(url).response { [weak self] resp in
            if let dd = resp.data {
                MemCacheManager.shared.setData(url.absoluteString, data: dd)
                if stopped {
                    return
                }
                self?.parseManifest(dd, url: url)
            } else {
                print("preload manifest failed")
            }
        }
    }
    
    final func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(
                in: text,
                range: NSRange(text.startIndex..., in: text)
            )

            var finalResult: [String] = []
            results.forEach {
                if let range = Range($0.range, in: text) {
                    finalResult.append(String(text[range]))
                }
            }
            return finalResult
        } catch {
            return []
        }
    }
    
    final func parseManifest(_ data: Data, url: URL) {
        
        playlistParser?.parse(playlistData: data,
                               url: url) { [weak self] parserRes in
            switch parserRes {
                
            case let .parsedMaster(playlist):
//                print("tags:\n \(playlist.tags)")
                for tag in playlist.tags {
                    if tag.tagDescriptor == PantosTag.EXT_X_STREAM_INF {
                        print(tag.tagData)
                        //in stream inf,we can extract video master link, but very tricky
                        print("====")
                        print(tag.keys)
                        print("====")
                    } else if tag.tagDescriptor == PantosTag.EXT_X_MEDIA {
                        let tagStr = tag.tagData.stringValue()
                        if let match = self?.matches(for: "URI=\"(.*?)\"", in: tagStr).first {
                            let startIndex = match.index(match.startIndex, offsetBy: "URI=\"".count)
                            let endIndex = match.index(match.endIndex, offsetBy: -2)
                            let subString = String(match[startIndex...endIndex])
                            print(subString)
                            if let lastPathComponent = url.lastPathComponent.range(of: ".", options: .backwards)?.lowerBound {
                                let uurl = url.deletingLastPathComponent().appendingPathComponent(subString)
                                if uurl.absoluteString.contains("audio") == true, !MemCacheManager.shared.audioMarked {
                                    MemCacheManager.shared.audioMarked.toggle()
                                    self?.preloadManifest(url: uurl, stopped: true)
                                    
                                } else if uurl.absoluteString.contains("video") == true, !MemCacheManager.shared.videoMarked {
                                    MemCacheManager.shared.videoMarked.toggle()
                                    self?.preloadManifest(url: uurl, stopped: true)
                                }
                            }
                        }
                    } else if tag.tagDescriptor == PantosTag.Location {
                        let tagStr = tag.tagData.stringValue()
                        let subString = tagStr
                            print(subString)
                        if let lastPathComponent = url.lastPathComponent.range(of: ".", options: .backwards)?.lowerBound {
                        let uurl = url.deletingLastPathComponent().appendingPathComponent(subString)
                        if uurl.absoluteString.contains("video") == true, !MemCacheManager.shared.videoMarked {
                                MemCacheManager.shared.videoMarked.toggle()
                                self?.preloadManifest(url: uurl, stopped: true)
                            }
                        }
                    }
                }
                break
            case let .parsedVariant(variant):
                print("variant \(variant.url)")
                break
            case let .parseError(err):
                print("parse manifest failued \(err)")
            }
        }
    }
}

extension Player: AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("media: \(loadingRequest.request.url)")
        let urlstr = loadingRequest.request.url?.absoluteString
        if urlstr?.contains(SCHEMA) == true, let surl = urlstr {
            let prefixIndex = surl.index(surl.startIndex, offsetBy: SCHEMA.count)
            let realstr = String(surl[prefixIndex...])
            print("modified url: \(realstr)")
            if realstr.contains(".m3u8") == true,
               let data = MemCacheManager.shared[realstr] {
                loadingRequest.dataRequest?.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                loadingRequest.redirect = try? URLRequest(url: URL(string: realstr )!, method: .get)
                loadingRequest.response = HTTPURLResponse(url: URL(string: realstr )!, statusCode: 302, httpVersion: nil, headerFields: nil)
                loadingRequest.finishLoading()
            }
            return true
        } else {
            loadingRequest.finishLoading()
            return false
        }
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        print("rl shouldWaitForRenewal")
        return true
    }

    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("rl didCancel")
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        print("rl authenticationChallenge")
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel authenticationChallenge: URLAuthenticationChallenge) {
        
    }
}
