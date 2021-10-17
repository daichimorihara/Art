//
//  PaletteChooser.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/17.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font {
        .system(size: emojiFontSize)
    }
    
    @EnvironmentObject var store: PaletteStore
    @State private var chosenIndex: Int = 0
    
    var body: some View {
        let palette = store.palette(at: chosenIndex)
        HStack {
            paletteControlButton
            body(for: palette)
        }
        .clipped()
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(emojiTransition)
        .popover(isPresented: $editMode) {
            PaletteEditor(palette: $store.palettes[chosenIndex])
        }
        .sheet(isPresented: $manageMode) {
            PaletteManager()
        }
    }
    
    private var emojiTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize),
                                 removal: .offset(x: 0, y: -emojiFontSize))
    }
    
    var paletteControlButton: some View {
        Button(action: {
            withAnimation {
                chosenIndex = (chosenIndex + 1) % store.palettes.count
            }
        }) {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }
    
    @State private var editMode = false
    @State private var manageMode = false
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            editMode = true
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: chosenIndex)
            editMode = true
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            chosenIndex = store.removePalette(at: chosenIndex)
        }
        gotoMenu
        AnimatedActionButton(title: "Manage", systemImage: "slider.vertical.3") {
            manageMode = true
        }
    }
    
    var gotoMenu: some View {
        Menu(content: {
            ForEach(store.palettes) {palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        chosenIndex = index
                    }
                }
            }
        }) {
            Label("Go To", systemImage: "text.insert")
        }
    }
}


struct ScrollingEmojisView: View {
    var emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map{ String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

