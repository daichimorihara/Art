//
//  ArtApp.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import SwiftUI

@main
struct ArtApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(artDocument: EmojiArtDocument())
        }
    }
}
