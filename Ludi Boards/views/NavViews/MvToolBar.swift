//
//  ToolBarView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/29/23.
//

import Foundation
import SwiftUI
import CoreEngine

// SwiftUI View for the Emoji Picker
struct ToolBarPicker<Content: View>: View {
    let content: Content
    @AppStorage("toolBarIsShowing") var toolBarIsShowing: Bool = false
    @Environment(\.colorScheme) var colorScheme
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private let soccerTools = SoccerToolProvider.allCases
    
    @State var gps = GlobalPositioningSystem()
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(getForegroundColor(colorScheme))
                    .padding()
                    .onTapAnimation {
                        self.toolBarIsShowing = false
                    }
                
                
                BorderedView(color: .red) {
                    content
                }
                
                BorderedView(color: .AIMYellow) {
                    ForEach(soccerTools, id: \.self) { tool in
                        ToolButtonIcon(icon: tool)
                    }
                }
                
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 75)
        .solBackground()
        
    }
    
}





