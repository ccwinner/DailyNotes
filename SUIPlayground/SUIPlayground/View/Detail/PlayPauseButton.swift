//
//  PlayPauseButton.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/4/11.
//

import SwiftUI
import Lottie

/// TODO: Expose the completion callback of animated button

// MARK: Lottie animation view in SwiftUI
struct AnimatedButtonRepresentable: UIViewRepresentable {
    let animationButton = AnimatedButton()
    var resource: LottieResource
    func makeUIView(context: Context) -> some UIView {
        animationButton
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        print(resource)
        animationButton.animation = .named(resource.rawValue)
        animationButton.animationView.loopMode = .playOnce
        animationButton.contentMode = .scaleAspectFit
    }
}


typealias PlayPauseTuple = (play: LottieResource,
                            pause: LottieResource)

struct PlayPauseButton: View {

    @State private var isPlaying = false

//    let playToPauseView = AnimatedButtonRepresentable(resource: .playToPause)
//    let pauseToPlayView = AnimatedButtonRepresentable(resource: .pauseToPlay)
    
    var body: some View {
        Button {
            isPlaying.toggle()
            print(isPlaying)
        } label: {
            if isPlaying {
                Image(systemName: SystemImage.player.sysName).foregroundColor(.white)
            } else {
                Image(systemName: SystemImage.pause.sysName).foregroundColor(.white)
            }
        }

//        AnimatedButtonRepresentable(resource: .pauseToPlay)
//        Button {
//            isPlaying.toggle()
//            if isPlaying {
//                pauseToPlayView.play(fromProgress: 0.0, toProgress: 1.0)
//            } else {
//                playToPauseView.play(fromProgress: 0.0, toProgress: 1.0)
//            }
//        } label: {
//            if isPlaying {
//                pauseToPlayView
//                    .background(Color.clear)
//                    .onDisappear {
//                        pauseToPlayView.play(fromProgress: 1.0, toProgress: 0.0)
//                    }
//            } else {
//                playToPauseView
//                    .background(Color.clear)
//                    .onAppear {
//                        playToPauseView.play(fromProgress: 0, toProgress: 1)
//                    }
//
//        }

    }
}
// MARK: End Lottie button definition

struct PlayPauseButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayPauseButton()
    }
}
