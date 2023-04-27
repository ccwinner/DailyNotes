//
//  VideoView.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/3/15.
//

import SwiftUI
import AVKit

// MARK: PlayerView in SwiftUI
struct PlayerViewRepresentable: UIViewRepresentable {

    var _player: AVPlayer?
    
    init(_ player: AVPlayer? = nil) {
        _player = player
    }

    func makeUIView(context: Context) -> some UIView {
        return PlayerView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let pv = uiView as? PlayerView, let _player else {
            return
        }
        pv.bind(with: _player)
    }
}


fileprivate let PlaybackWidthInPortrait = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

fileprivate let PlaybackHeightInPortrait = PlaybackWidthInPortrait * 9 / 16

struct VideoView: View {
    let preloadType: PreloadType
    @StateObject var player = Player(preloadType: .unknown)
    
    init(preloadType: PreloadType) {
        self.preloadType = preloadType
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                
                PlayerViewRepresentable( player.player)
                Button {
                    player.seekToTheEnd()
                    if player.preloadType == .manifest {
                        player.preloadManifest(url: URL(string: nextContentLink)!)
                    } else if player.preloadType == .multiplePlayers {
                        player.preloadInParallel(url: URL(string: nextContentLink)!)
                    } else {
                        ///do nothing
                    }
                } label: {
                    Image(systemName: SystemImage.forwardToEnd.sysName).foregroundColor(.white)
                }.padding(.init(top: 20, leading: 0, bottom: 0, trailing: 20))
                
                
            }.frame(width: PlaybackWidthInPortrait, height: PlaybackHeightInPortrait)
            HStack {
                Text("demo 1").padding(.init(top: 12, leading: 20, bottom: 0, trailing: 0))
                Spacer()
            }
            Spacer()
        }.onDisappear {
            MemCacheManager.shared.reset()
            HTTPCookieStorage.shared.removeCookies(since: .distantPast)
            player.stopPlayback()
        }.onAppear {
            player.preloadType = preloadType
            player.play(with: URL(string: curContentLink)!)
        }.background(.black)
    }

    private var curContentLink: String {
        "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    }
    private var nextContentLink: String {
//        let randomNum = Int.random(in: 1...10)
//        return randomNum < 6 ? "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8" :
        "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8"
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(preloadType: .manifest)
    }
}
