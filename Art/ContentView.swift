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
                Color.yellow.overlay(
                    OptionalImage(uiImage: artDocument.backgroundImage)
                        .position(convertFromEmojiCoordinate((0,0), in: geometry))
                )
                if artDocument.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                } else {
                    ForEach(artDocument.emojis) {emoji in
                        Text(emoji.text)
                            .font(.system(size: CGFloat(emoji.size)))
                            .position(position(emoji: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            artDocument.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    artDocument.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    artDocument.addEmoji(
                        text: String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultFontSize)
                }
            }
        }
        return found
    }
    
    private func position(emoji: EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
        )
        return (Int(location.x), Int(location.y))
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
                            .onDrag { NSItemProvider(object: emoji as NSString) }
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
