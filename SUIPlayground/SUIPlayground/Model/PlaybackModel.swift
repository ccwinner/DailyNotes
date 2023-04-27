//
//  DetailModel.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/4/23.
//

//import Foundation



//class PlaybackModel: ObservableObject {
//    @Published var curPlayer: Player?
//    private var contentLink: String?
//    func load(url: String) {
//        contentUrl = url
//        let asset = AVURLAsset(url: url)
//        asset.resourceLoader.setDelegate(self, queue: .main)
//        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
//            var error: NSError? = nil
//            let status = asset.statusOfValue(forKey: "playable", error: &error)
//            switch status {
//            case .loaded:
//                let playerItem = AVPlayerItem(asset: asset)
//                DispatchQueue.main.async { [weak self] in
//                    self?.player = AVPlayer(playerItem: playerItem)
//                    self?.playerItem = playerItem
//                    if let self = self {
//                        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
//                    }
//
//                }
//            case .failed:
//                print(".failed\n\(error)")
//            case .cancelled:
//                print(".cancelled\n\(error)")
//            default:
//                break
//            }
//        }
//    }
//}

//class VideoViewModel: ObservableObject {
//    var urlstr: String?
//    var preloadType: PreloadType
//    var player: Player?
//    init(preloadType: PreloadType) {
//        self.preloadType = preloadType
//    }
//
//    func configurePlayer(link: String?) {
//        urlstr = link
//        if let urlstr {
//            player = Player(preloadType: preloadType)
//            player?.play(with: URL(string: urlstr)!)
//        }
//    }
//
//    func seekToTheEnd() {
//        var duration: Float64 = 0
//        if let seekableRange = player?.playerItem?.seekableTimeRanges.last?.timeRangeValue, CMTIMERANGE_IS_VALID(seekableRange) {
//                let dur = CMTimeGetSeconds(seekableRange.duration)
//                if dur.isNaN == false, dur.isInfinite == false {
//                    duration = dur
//                }
//            let ts = CMTimeMakeWithSeconds(duration * 0.9, preferredTimescale: 100_000)
//            player?.playerItem?.seek(to: ts, completionHandler: nil)
//        } else {
//            print("Failed to seek end")
//        }
//    }
//
//    func preloadManifest(url: URL?) {
//        player?.preloadManifest(url: url)
//    }
//
//    func stopPlayback() {
//        player?.stop()
//    }
//}

