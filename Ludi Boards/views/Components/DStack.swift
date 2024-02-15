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

#Preview {
    DStack() {
        
    }
}
