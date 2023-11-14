//
//  CanvasViewV2.swift
//  iosLudiSports
//
//  Created by Charles Romeo on 11/8/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct CanvasEngine: View {
    
    @State var cancellables = Set<AnyCancellable>()
    
    var maxScaleFactor: CGFloat = 1.0
    @State private var totalScale: CGFloat = 0.15
    @GestureState private var gestureScale: CGFloat = 1.0
    
    @State private var offset = CGPoint.zero
    @State private var lastOffset = CGPoint.zero
    
    @State private var position = CGPoint(x: 50, y: 50) // Initial position
    @GestureState private var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 4000
    let initialHeight: CGFloat = 4000
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack() {
                DrawGridLines()
                BoardEngine()
            }
            .zIndex(0)
            .frame(width: initialWidth, height: initialHeight)
            .scaleEffect(min(totalScale * gestureScale, maxScaleFactor), anchor: UnitPoint(x: self.offset.x, y: self.offset.y))
        }
        .zIndex(0)
        .gesture(
            MagnificationGesture()
                .updating($gestureScale) { value, gestureScale, _ in gestureScale = value }
                .onEnded { value in totalScale *= value }
            )
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let translation = gesture.translation
                    self.offset = CGPoint(
                        x: self.lastOffset.x + (translation.width / self.totalScale),
                        y: self.lastOffset.y + (translation.height / self.totalScale)
                    )
                }
                .onEnded { _ in self.lastOffset = self.offset}
                .updating($dragOffset) { value, state, _ in state = value.translation }
        )
    }
    
}

struct LargeCanvasView2_Previews: PreviewProvider {
    static var previews: some View {
        CanvasEngine()
    }
}
