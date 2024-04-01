//
//  Text.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/20/24.
//

import Foundation
import SwiftUI

struct TextLabel: View {
    var title: String
    var subtitle: String
    
    init(_ title: String, text: String) {
        self.title = title
        self.subtitle = text
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline) // Bold and slightly larger font for the title
                .foregroundColor(.blue) // Adaptable to light/dark mode
                .padding(.trailing)
            Spacer()
            Text(subtitle)
                .font(.headline) // Slightly smaller font for the subtitle
                .foregroundColor(.black) // A subtler color to distinguish from the title
            
        }
        .padding(.all, 10) // Padding around the HStack for better touch targets
//        .background(RoundedRectangle(cornerRadius: 10) // Rounded background for a modern look
//                        .fill(Color(.systemBackground)) // Adaptable background color
//                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)) // Soft shadow for depth
    }
}


func HeaderText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(color)
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .mask(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
        )
}


func SubHeaderText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(color)
        .kerning(1.5)
        .underline()
}

func TitleText(_ content: String, color:Color = .white) -> some View {
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



func BodyText(_ content: String, color:Color = .white) -> some View {    
    Text(content)
        .font(.system(size: 18))
        .lineSpacing(4)
        .foregroundColor(color)
}

func MenuBarText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 12))
        .bold()
        .lineSpacing(4)
        .foregroundColor(color)
}

func DisclaimerText(_ content: String, color:Color = .white) -> some View {
    Text(content)
        .font(.system(size: 14))
        .foregroundColor(color)
        .italic()
        .opacity(0.6)
}

// Alightments
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
