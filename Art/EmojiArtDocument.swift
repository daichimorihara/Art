//
//  EmojiArtDocument.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published var emojiArt: EmojiArt
    
    init() {
        emojiArt = EmojiArt()
        emojiArt.addEmoji(text: "🎖", at: (100, 130), size: 80)
    }
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    var background: EmojiArt.Background { emojiArt.background }
    
    // Mark - Intent
    
    //add move pintch delete and now what
    func setBackgorund(_ background: EmojiArt.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(text: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(text: text, at: location, size: Int(size))
    }
    
    func moveEmoji(emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size *= Int(scale)
        }
    }
    
    
}
