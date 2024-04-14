//
//  Text.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/20/24.
//

import Foundation
import SwiftUI

public func HeaderText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(color)
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .mask(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
        )
}


public func SubHeaderText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(color)
        .kerning(1.5)
        .underline()
}

public func TitleText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 20, weight: .medium, design: .serif))
        .foregroundColor(color)
        .italic()
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
}



public func BodyText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 18))
        .lineSpacing(4)
        .foregroundColor(color)
}

public func MenuBarText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 12))
        .bold()
        .lineSpacing(4)
        .foregroundColor(color)
}

public func DisclaimerText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 14))
        .foregroundColor(color)
        .italic()
        .opacity(0.6)
}

// Alightments
public struct AlignLeft<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            content()
            Spacer()
        }
    }
}

public struct AlignRight<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            content()
        }
    }
}

public struct AlignCenter<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}
