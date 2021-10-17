//
//  ArtApp.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import SwiftUI

@main
struct ArtApp: App {
    @StateObject var document = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtView(artDocument: document)
                .environmentObject(paletteStore)
        }
    }
}
