//
//  FloatingButtons.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/30/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct FloatingProfileView: View {
    @State private var verticalMovement = false
    @State private var horizontalMovement = false
    
    // Customizable parameters
    var profileImageDiameter: CGFloat = 180  // Diameter of the profile image circle
    var orbitRadius: CGFloat = 100          // Radius of the orbit for the buttons

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.gray.opacity(0.2))
                .frame(width: profileImageDiameter + 20, height: profileImageDiameter + 20)
                .overlay(
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: profileImageDiameter, height: profileImageDiameter)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                )

            ForEach(0..<5) { i in
                Button(action: {
                    // Action for the button
                }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .shadow(radius: 5)
                }
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white).shadow(radius: 5))
                .offset(x: cos(CGFloat(i) / CGFloat(5) * 2 * .pi) * orbitRadius + (horizontalMovement ? 5 : -5),
                        y: sin(CGFloat(i) / CGFloat(5) * 2 * .pi) * orbitRadius + (verticalMovement ? 5 : -5))
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: verticalMovement
                )
                .animation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true),
                    value: horizontalMovement
                )
            }
        }
        .frame(width: orbitRadius * 2 + 80, height: orbitRadius * 2 + 80)
        .onAppear {
            verticalMovement.toggle()
            horizontalMovement.toggle()
        }
    }
}

struct FadingBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            RadialGradient(gradient: Gradient(colors: [.blue, .clear]),
                           center: .center,
                           startRadius: -(geometry.size.width * 0.9),
                           endRadius: geometry.size.width / 2)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)  // Optional, to extend the background to the edges of the display
    }
}

struct FloatingProfileView2: View {
    @State private var verticalMovement = false
    @State private var horizontalMovement = false
    @State private var scale: CGFloat = 1.0  // Persistent scale state
    @State private var viewOffset: CGSize = .zero  // State for dragging offset
    @GestureState private var dragState: CGSize = .zero  // Temporary state during a drag

    // Customizable parameters
    var profileImageDiameter: CGFloat = 180  // Diameter of the profile image circle
    var orbitRadius: CGFloat = 100          // Radius of the orbit for the buttons

    var body: some View {
        ZStack {
            ChatView()
                .frame(width: 500 * scale, height: 500 * scale)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .offset(x: 35, y: 0)
            ForEach(0..<5) { i in
                Button(action: {
                    // Action for the button
                }) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 30 * scale, height: 30 * scale) // Scale buttons too
                        .foregroundColor(.yellow)
                        .shadow(radius: 5)
                }
                .frame(width: 55 * scale, height: 55 * scale) // Scale buttons too
                .background(Circle().fill(Color.white).shadow(radius: 5))
                .offset(x: cos(CGFloat(i) / CGFloat(5) * 2 * .pi) * orbitRadius * scale + (horizontalMovement ? 5 : -5),
                        y: sin(CGFloat(i) / CGFloat(5) * 2 * .pi) * orbitRadius * scale + (verticalMovement ? 5 : -5))
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: verticalMovement
                )
                .animation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true),
                    value: horizontalMovement
                )
            }
        }
        .scaleEffect(scale) // Apply the scaling factor to the entire view
        .offset(x: viewOffset.width + dragState.width, y: viewOffset.height + dragState.height)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = value
                }
                .onEnded { value in
                    scale = value
                }
        )
        .simultaneousGesture(
            DragGesture()
                .updating($dragState, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onEnded { value in
                    viewOffset = CGSize(width: viewOffset.width + value.translation.width,
                                        height: viewOffset.height + value.translation.height)
                }
        )
        .frame(width: (orbitRadius * 2 + 80) * scale, height: (orbitRadius * 2 + 80) * scale)
        .onAppear {
            verticalMovement.toggle()
            horizontalMovement.toggle()
        }
    }
}



struct CarouselView: View {
    let icons: [String] = ["house.fill", "bell.fill", "person.fill", "gear", "star.fill"]
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(icons, id: \.self) { icon in
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                            .padding()
                            .rotation3DEffect(
                                .degrees(Double(geometry.size.width / 2 - scrollOffset) / -20),
                                axis: (x: 0, y: 1, z: 0)
                            )
                    }
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: scrollOffset)
                .gesture(
                    DragGesture().onChanged { value in
                        scrollOffset = value.translation.width - geometry.size.width * CGFloat(icons.count - 1) / 2
                    }
                    .onEnded { _ in
                        withAnimation {
                            scrollOffset = round(scrollOffset / geometry.size.width) * geometry.size.width
                        }
                    }
                )
            }
        }
        .frame(width: 200, height: 100)
    }
}
