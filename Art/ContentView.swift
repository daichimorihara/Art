//
//  ContentView.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var artDocument: EmojiArtDocument
    let defaultFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            artBody
            palette
        }
    }
    
    var artBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.yellow
                ForEach(artDocument.emojis) {emoji in
                    Text(emoji.text)
                        .font(.system(size: CGFloat(emoji.size)))
                        .position(position(emoji: emoji, in: geometry))
                }
            } 
        }
    }
    private func position(emoji: EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(location.x),
                       y: center.y + CGFloat(location.y))
    }
    
    
    let testEmojis = "🎖🥇🏆🎫🎫🎟🎬🎨🎼🎷🎺🪗🥁🪘🎧🎲🎳🧩🚗🚎🍏🍎🍐🍊🍇🍉🍌🍋🍓🫐🍈🍒🥥🍍🥭🍑🥝🍅🍆🥑🚐🚓🚌"
    var palette: some View {
        ScrollView(.horizontal) {
                HStack {
                    ForEach(testEmojis.map{ String($0) }, id: \.self) {emoji in
                        Text(emoji)
                            .font(.system(size: defaultFontSize))
                    }
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(artDocument: EmojiArtDocument())
    }
}
