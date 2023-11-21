//
//  MenuBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct MenuBarWindow<Content>: View where Content: View {
    let items: [() -> Content]
    
    @State private var isEnabled = true // Replace with your actual condition
    @State private var overrideColor = false // Replace with your actual condition
    @State private var color: Color = .blue // Replace with your actual color
    
//    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: -200, y: -200)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 24)
            ForEach(0..<items.count, id: \.self) { index in
                self.items[index]().foregroundColor(.white)
            }
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: 50, maxHeight: 50 * Double(items.count))
        .padding(8)
        .shadow(radius: 15)
        .background(Color(hex: "3E7167"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .offset(x: position.x + (isDragging ? dragOffset.width : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onChanged { _ in
                    self.isDragging = true
                }
                .onEnded { value in
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        )
    }
}
