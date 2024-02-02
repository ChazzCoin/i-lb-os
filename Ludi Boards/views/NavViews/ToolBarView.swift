//
//  ToolBarView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/29/23.
//

import Foundation
import SwiftUI

// SwiftUI View for the Emoji Picker
struct ToolBarPicker<Content: View>: View {
    let content: Content
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
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        
    }
    
}





