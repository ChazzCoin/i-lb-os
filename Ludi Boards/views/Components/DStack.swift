//
//  DStack.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/18/24.
//

import SwiftUI

struct DStack<Content: View>: View {
    @State var isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    @State var isPortrait: Bool = UIDevice.current.orientation == .portrait
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        
        if isPhone || isPortrait {
            VStack { content() }
        } else {
            HStack { content() }
        }
        
    }
}


struct AdaptiveStack<Content: View>: View {
    let content: () -> Content
    @Environment(\.horizontalSizeClass) var sizeClass

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            if sizeClass == .compact || geometry.size.width < geometry.size.height {
                VStack { content() }
            } else {
                HStack { content() }
            }
        }
    }
}

#Preview {
    DStack() {
        
    }
}


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
                
            Text(subtitle)
                .font(.headline) // Slightly smaller font for the subtitle
                .foregroundColor(.black) // A subtler color to distinguish from the title
            Spacer()
        }
        .padding(.all, 10) // Padding around the HStack for better touch targets
//        .background(RoundedRectangle(cornerRadius: 10) // Rounded background for a modern look
//                        .fill(Color(.systemBackground)) // Adaptable background color
//                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)) // Soft shadow for depth
    }
}
