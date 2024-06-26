//
//  FloatingEmoji.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import Combine


public struct FloatingEmojiView: View {
    @State public var emojiInstances = [UUID]()
    @State public var currentEmoji: String = EmojiProvider.heart.rawValue
    public var sWidth = UIScreen.main.bounds.width
    public var sHeight = UIScreen.main.bounds.height
    @State public var cancellables = Set<AnyCancellable>()
    @State public var gps = GlobalPositioningSystem(CoreNameSpace.local)
    
    
    public init(emojiInstances: [UUID] = [UUID](), currentEmoji: String = EmojiProvider.heart.rawValue) {
        self.emojiInstances = emojiInstances
        self.currentEmoji = currentEmoji
    }
    
    public var body: some View {
        ZStack {

            EmojiPicker() { item in
                currentEmoji = item.rawValue
                addEmojiInstance()
            }

            // Displaying all the emoji instances
            ForEach(emojiInstances, id: \.self) { id in
                let tempX = CGFloat.random(in: -150...150)
                FloatingEmoji(emoji: currentEmoji, xCoord: tempX, id: id)
                    .offset(x: 0, y: 50)
                    .zIndex(20.0)
            }
        }
        .frame(width: 400, height: 400)
        .background(Color.clear)
//        .offset(x: gps.getCoordinate(for: .topLeft).x, y: gps.getCoordinate(for: .topLeft).y + 50)
        .onAppear() {
            CodiChannel.EMOJI_ON_CREATE.receive(on: RunLoop.main) { emoji in
                print("Received on EMOJI_ON_CREATE channel: \(emoji)")
                currentEmoji = emoji as? String ?? EmojiProvider.heart.rawValue
                addEmojiInstance()
            }.store(in: &cancellables)
        }
    }

    private func addEmojiInstance() {
        withAnimation {
            emojiInstances.append(UUID())
        }
        
        // Optional: Remove the instance after animation to clear memory
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emojiInstances.removeAll { $0 == emojiInstances.first }
        }
    }
}

struct FloatingEmoji: View {
    @State var emoji: String
    @State var xCoord: Double
    var id: UUID
    @State var directionIsUp: Bool = false
    let animationDuration: TimeInterval = 3

    @State private var isFloating = false
    @State private var isFaded = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 40))
            .opacity(isFaded ? 0 : 1)
            .offset(x: xCoord, y: isFloating ? (directionIsUp ? -200 : 200) : 0) // Increased offset for a continuous upward movement
            .animation(.easeInOut(duration: animationDuration), value: isFloating)
            .onAppear {
                withAnimation {
                    isFloating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 2) {
                    withAnimation {
                        isFaded = true
                    }
                }
            }
    }
}

//#Preview {
//    FloatingEmojiView()
//}

