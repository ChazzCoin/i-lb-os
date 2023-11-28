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
    
    @ObservedObject private var gps = GlobalPositioningSystem()
    @State private var position = CGPoint(x: 100, y: 300)
    @State private var screen = UIScreen.main
    
    @State private var offset = CGSize.zero // Initial offset
    @GestureState private var dragState = CGSize.zero // Temporary state during a drag


    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 24)
            ForEach(0..<items.count, id: \.self) { index in
                self.items[index]()
                    .padding(.vertical, 5)
            }
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: 55, maxHeight: 50 * Double(items.count))
        .padding(8)
//        .background(Color(hex: "3E7167"))
//        #00BFFF, 0093C1, 007DA2
        .background(Color(hex: "3BAF6C"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
//        .position(position)
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    self.position = value.location
//                }
//        )
        .offset(x: offset.width + dragState.width, y: offset.height + dragState.height)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in
                    state = CGSize(width: value.translation.width, height: value.translation.height)
                }
                .onEnded { value in
                    self.offset.width += value.translation.width
                    self.offset.height += value.translation.height
                }
        ).onAppear() {
            self.offset = gps.getOffset(for: .bottomLeft)
        }
    }
}

struct MenuBarWindow2<Content>: View where Content: View {
    let items: [() -> Content]
    
    @State private var position = CGPoint(x: 100, y: 300)
    private let screenSize = UIScreen.main.bounds

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<items.count, id: \.self) { index in
                self.items[index]()
//                    .foregroundColor(Color.primary) // System primary color
            }
        }
        .frame(width: 60, height: CGFloat(60 * items.count)) // Adjust size
        .padding(10)
        .background(Color(UIColor.systemBackground)) // Use system background color
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .position(position.clamped(to: screenSize))
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.position = value.location.clamped(to: screenSize)
                }
        )
    }
}

