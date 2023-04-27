//
//  HomeData.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/3/15.
//

import Foundation


enum SystemImage {
    case player
    case messenger
    case pause
    case forwardToEnd
    
    var sysName: String {
        switch self {
        case .player:
            return "play.fill"
        case .messenger:
            return "ellipsis.message.fill"
        case .pause:
            return "pause.fill"
        case .forwardToEnd:
            return "forward.end.alt.fill"
        }
    }
}

enum PreloadType {
    case manifest
    case avQueuePlayer
    case multiplePlayers
    case unknown
    
    var description: String {
        switch self {
        case .manifest:
            return "Powered by manifest preloading"
        case .avQueuePlayer:
            return "Powered by AVQueuePlayer preloading"
        case .multiplePlayers:
            return "Powered by multi-player preloading"
        default:
            return "No preloading"
        }
    }
}

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let image: SystemImage
    let title: String
    let ptype: PreloadType
    
    static let example = MenuItem(image: .player, title: "playback demo", ptype: .manifest)
}
