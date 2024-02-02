//
//  Text.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/20/24.
//

import Foundation
import SwiftUI


struct AlignLeft<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            content()
            Spacer()
        }
    }
}

struct AlignRight<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            Spacer()
            content()
        }
    }
}

struct AlignCenter<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

func HeaderText(_ content: String) -> some View {
    Text(content)
        .font(.system(size: 24, weight: .bold))
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .mask(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
        )
}


func SubHeaderText(_ content: String) -> some View {
    Text(content)
        .font(.system(size: 20, weight: .semibold))
        .kerning(1.5)
        .underline()
}

func TitleText(_ content: String) -> some View {
    Text(content)
        .font(.system(size: 20, weight: .medium, design: .serif))
        .italic()
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
}



func BodyText(_ content: String, color:Color = .white) -> some View {    
    Text(content)
        .font(.system(size: 18))
        .lineSpacing(4)
        .foregroundColor(color)
}

func DisclaimerText(_ content: String) -> some View {
    Text(content)
        .font(.system(size: 14))
        .italic()
        .opacity(0.6)
}


