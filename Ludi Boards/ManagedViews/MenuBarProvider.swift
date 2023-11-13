//
//  MenuBarProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI

struct Tool {
    let title: String
    let image: Image // Using SwiftUI's Image type for image resources
    let authLevel: Int
    let color: Color
}

protocol IconProvider {
    var soccerTool: SoccerTool { get }
}


struct MenuButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View
//    var channel: CodiChannel  Define this according to your needs
//    var codiAction: CodiActions // Enum or other type representing actions

    @State private var isLocked = false

    var body: some View {
        VStack {
            icon.soccerTool.image
                .resizable()
                .frame(width: 45, height: 45)
                .onTapGesture {
                    print("CodiChannel SendTopic: \(icon.soccerTool.title)")
                    // Implement your channel logic here
                }
                .foregroundColor(isLocked ? .red : Color.primary)
            Spacer().frame(height: 16)
        }
        .onAppear {
            // Update isLocked state based on your conditions
        }
    }
}

struct MenuBarFloatingWindow<Content>: View where Content: View {
    let content: Content
    @State private var offset = CGSize.zero
    @State private var isEnabled = true // Replace with your actual condition
    @State private var overrideColor = false // Replace with your actual condition
    @State private var color: Color = .gray // Replace with your actual color
    
    @State private var position = CGPoint(x: 500, y: 500)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if isEnabled {
                content
                    .zIndex(20)
                    .frame(maxWidth: 200, maxHeight: 500)
                    .background(color)
                    .shadow(radius: 10)
                    .offset(x: offset.width, y: offset.height)
                    .position(x: position.x + (isDragging ? dragOffset.width : 0),
                              y: position.y + (isDragging ? dragOffset.height : 0))
                    .overlay(
                        Rectangle() // The rectangle that acts as the border
                            .stroke(Color.white, lineWidth: 2) // Red border with a stroke width of 2
                            .frame(width: 200, height: 500)
                            .offset(x: offset.width, y: offset.height)
                            .position(x: position.x + (isDragging ? dragOffset.width : 0),
                                      y: position.y + (isDragging ? dragOffset.height : 0))
                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .gesture(
                        LongPressGesture(minimumDuration: 0.05)
                            .onEnded { _ in
                                self.isDragging = true
                            }
                            .sequenced(before: DragGesture())
                            .updating($dragOffset, body: { (value, state, transaction) in
                                switch value {
                                case .second(true, let drag):
                                    state = drag?.translation ?? .zero
                                default:
                                    break
                                }
                            })
                            .onEnded { value in
                                if case .second(true, let drag?) = value {
                                    // Update the final position when the drag ends
                                    self.position = CGPoint(x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                                    self.isDragging = false
                                }
                            }
                    )
            }
        }
    }
}


struct LazyColumnForComps<Content>: View where Content: View {
    let items: [() -> Content]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { index in
                    self.items[index]()
                }
            }
            .padding(8)
        }
    }
}
