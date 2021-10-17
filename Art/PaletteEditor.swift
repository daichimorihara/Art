//
//  PaletteEditor.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/17.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    
    var body: some View {
        Form {
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .frame(minWidth: 300, minHeight: 350)
        .navigationTitle("Edit \(palette.name)")
        
    }
    
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
        }
    }

    @State private var emojisToAdd: String = ""
    
    var addEmojiSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmoji(emojis)
                }
        }
    }
    
    func addEmoji(_ emojis: String) {
        palette.emojis = palette.emojis + emojis
            .filter{ $0.isEmoji }
            .removingDuplicateCharacters
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emojis")) {
            let emojis = palette.emojis.removingDuplicateCharacters.map{ String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
}
