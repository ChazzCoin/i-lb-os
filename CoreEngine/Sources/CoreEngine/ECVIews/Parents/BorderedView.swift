//
//  BorderedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/30/23.
//

import Foundation
import SwiftUI

public struct BorderedView<Content: View>: View {
    public let content: Content
    public var borderColor: Color = .white
    public var borderWidth: CGFloat = 2

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public init(color:Color, @ViewBuilder content: () -> Content) {
        self.borderColor = color
        self.content = content()
    }

    public var body: some View {
        HStack {
            content
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8) // Adjust corner radius as needed
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
}

public struct BorderedVStack<Content: View>: View {
    public let content: Content
    public var borderColor: Color = .blue
    public var borderWidth: CGFloat = 2

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public init(color:Color, @ViewBuilder content: () -> Content) {
        self.borderColor = color
        self.content = content()
    }

    public var body: some View {
        VStack {
            content
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8) // Adjust corner radius as needed
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
}
