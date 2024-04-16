//
//  EmojiProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

public enum EmojiProvider: String, CaseIterable {
    case smile = "😊"
    case laugh = "😂"
    case heart = "❤️"
    case thumbsUp = "👍"
    case crying = "😢"
    case thinking = "🤔"
    // Add more emojis as needed
}

public func emojiList() -> [String] {
    return EmojiProvider.allCases.map { $0.rawValue }
}

// SwiftUI View for the Emoji Picker

public struct EmojiPicker: View {
    public var onEmojiSelected: (EmojiProvider) -> Void
    
    public var sWidth = UIScreen.main.bounds.width
    public var sHeight = UIScreen.main.bounds.height
    
    public init(onEmojiSelected: @escaping (EmojiProvider) -> Void, sWidth: CGFloat = UIScreen.main.bounds.width, sHeight: CGFloat = UIScreen.main.bounds.height) {
        self.onEmojiSelected = onEmojiSelected
        self.sWidth = sWidth
        self.sHeight = sHeight
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(EmojiProvider.allCases, id: \.self) { emoji in
                    Text(emoji.rawValue)
                        .font(.largeTitle)
                        .padding(2)
                        .onTapGesture {
                            onEmojiSelected(emoji)
                        }
                }
            }
        }
        .frame(width: 300, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color(UIColor.systemBackground).opacity(0.8))
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .zIndex(20.0)
    }
}


