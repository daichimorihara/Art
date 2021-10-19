//
//  PaletteManager.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/17.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore
    
    @State private var editMode: EditMode = .inactive
    @Environment (\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name).font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newSet in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newSet )
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}
