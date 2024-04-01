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
