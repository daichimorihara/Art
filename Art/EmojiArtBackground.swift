//
//  EmojiArtBackground.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import Foundation

extension EmojiArt {
    enum Background {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var data: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
