//
//  ContentView.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/3/12.
//

import SwiftUI

struct ContentView: View {
    private let menuItems: [MenuItem] = [
        .init(image: .player, title: "Video Playback Preload - manifest only", ptype: .manifest),
        .init(image: .player, title: "Video Playback Preload - multiple players", ptype: .multiplePlayers),
        .init(image: .player, title: "No preload playback", ptype: .unknown)
    ]
    var body: some View {
        NavigationStack {
            List(menuItems) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }

            }.navigationTitle("Menu")
            .listStyle(.grouped)
            .navigationDestination(for: MenuItem.self) { item in
                destinationView(item: item)
            }
        }
    }
    
    private func destinationView(item: MenuItem) -> some View {
        if case .player = item.image {
            return AnyView(VideoView(preloadType: item.ptype))
        }
        return AnyView(MessengerView())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
