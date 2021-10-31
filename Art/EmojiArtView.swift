//
//  EmojiArtView.swift
//  Art
//
//  Created by Daichi Morihara on 2021/10/10.
//

import SwiftUI

struct EmojiArtView: View {
    @ObservedObject var artDocument: EmojiArtDocument
    let defaultFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            artBody
            PaletteChooser()
        }
    }
    
    var artBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.yellow.overlay(
                    OptionalImage(uiImage: artDocument.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinate((0,0), in: geometry))
                )
                    .gesture(doubleTapToZoom(in: geometry.size))
                
                if artDocument.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(3)
                } else {
                    ForEach(artDocument.emojis) {emoji in
                        Text(emoji.text)
                            .font(.system(size: CGFloat(emoji.size) * zoomScale))
                            .position(position(emoji: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: artDocument.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
            .onReceive(artDocument.$backgroundImage) { image in
                zoomToFit(image, in: geometry.size)
            }
        }
    }
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(title: Text("Background Image Fetch"),
                  message: Text("Couldn't load image from \(url)"),
                  dismissButton: .default(Text("OK")))
        })
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
                        size: defaultFontSize / zoomScale)
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
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y -  panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
                       y: center.y + CGFloat(location.y) * zoomScale + panOffset.height )
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                zoomToFit(artDocument.backgroundImage, in: size)
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, size.width > 0, size.height > 0, image.size.width > 0, image.size.height > 0 {
            let  hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
            steadyStatePanOffset = .zero
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtView(artDocument: EmojiArtDocument())
    }
}
