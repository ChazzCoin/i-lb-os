//
//  File.swift
//  
//
//  Created by Charles Romeo on 5/2/24.
//

import Foundation
import SwiftUI


public struct FloatingSocialView: View {
    public init() {}
    
    @State public var isExpanded: Bool = true
    @State public var scale: CGFloat = 1.2  // Persistent scale state
    @State public var lastScale: CGFloat = 1.0
    @State public var viewOffset: CGSize = .zero  // State for dragging offset
    @GestureState public var dragState: CGSize = .zero
    public var orbitRadius: CGFloat = 140  // Radius of the orbit for the buttons
    
    public var doorOpenIcon: String = "door.open"
    public var doorClosedIcon: String = "door.closed"
    // Icons for the buttons - including one for the toggle
    public let buttonIcons = [
        ViewEngine.Tool.GeneralTool.moon.name,
        ViewEngine.Tool.GeneralTool.heart.name,
        ViewEngine.Tool.GeneralTool.message.name,
        ViewEngine.Tool.GeneralTool.cube.name,
        ViewEngine.Tool.GeneralTool.cloudMoon.name,
        ViewEngine.Tool.GeneralTool.pencil.name
    ]

    public var body: some View {
        ZStack {
            
//            RoomWindow(selectedFeature: <#T##Binding<FusedRoomFeature>#>)
//                .frame(width: 220 * scale, height: 220 * scale)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .shadow(radius: 10)
//                .offset(x: 0, y: 0)
//                .scaleEffect(isExpanded ? 1 : 0.1) // Scales down when not expanded
//                .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isExpanded)
            FloatingEmojiView()
                .frame(width: 300 * scale)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .offset(x: 0, y: -200)
                .scaleEffect(isExpanded ? 1 : 0.1) // Scales down when not expanded
                .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isExpanded)
            
            ForEach(0..<buttonIcons.count) { i in
                
                Image(systemName: buttonIcons[i])
                    .resizable()
                    .frame(width: 20 * scale, height: 20 * scale)
                    .foregroundColor(i == 0 ? (isExpanded ? .red : .green) : .yellow)
                    .onTapAnimation {
                        if i == 0 {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                        else if i == 1 {}
                        else if i == 2 {}
                        else if i == 3 {}
                        else if i == 4 {}
                    }
                    .background(Circle().fill(Color.white).frame(width: 35 * scale, height: 35 * scale))
                    .zIndex(i == 0 ? 50.0 : 25.0)
                .offset(x: isExpanded ? cos(CGFloat(i) / CGFloat(buttonIcons.count) * 2 * .pi) * orbitRadius * scale : 0,
                        y: isExpanded ? sin(CGFloat(i) / CGFloat(buttonIcons.count) * 2 * .pi) * orbitRadius * scale : 0)
                .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(i == 0 ? 0 : 0.1 * Double(i)), value: isExpanded)
            }
        }
        .scaleEffect(scale) // Apply the scaling factor to the entire view
        .offset(x: viewOffset.width + dragState.width, y: viewOffset.height + dragState.height)
        .gesture(
            DragGesture()
                .updating($dragState, body: { (value, state, transaction) in
                    withAnimation { state = value.translation }
                })
                .onEnded { value in
                    viewOffset = CGSize(width: viewOffset.width + value.translation.width,
                                        height: viewOffset.height + value.translation.height)
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    withAnimation { scale = delta.bounded(byMin: 1.0, andMax: 1.5) }
                    lastScale = value
                }
                .onEnded { value in
//                    lastScale = 1.0
                    withAnimation { scale = value.bounded(byMin: 1.0, andMax: 1.5) }
                }
        )
        .frame(width: (orbitRadius * 2 + 80) * scale, height: (orbitRadius * 2 + 80) * scale)
        .onAppear {
            isExpanded = true
        }
    }
}

