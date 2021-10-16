//
//  EmojiArt.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import Foundation

struct EmojiArt: Codable {
    var emojis = [Emoji]()
    var background = Background.blank
    
    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        let id: Int

        fileprivate init(text: String, at position: (x: Int, y: Int), size: Int, id: Int) {
            self.text = text
            self.x = position.x
            self.y = position.y
            self.size = size
            self.id = id
        }
    }
    
    init() {}
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init(url: URL) throws {
        let data =  try Data(contentsOf: url)
        self = try EmojiArt(json: data)
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    private var uniqueID = 0
    
    mutating func addEmoji(text: String, at position: (x: Int, y: Int), size: Int) {
        uniqueID += 1
        emojis.append(Emoji(text: text, at: position, size: size, id: uniqueID))
    }
}
