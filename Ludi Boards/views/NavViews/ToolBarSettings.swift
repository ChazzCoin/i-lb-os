//
//  ToolBarSettings.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/6/23.
//

import Foundation
import SwiftUI

// SwiftUI View for the Emoji Picker
struct ToolBarSettingsPicker<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private let soccerTools = SoccerToolProvider.allCases
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
               
                ForEach(soccerTools, id: \.self) { tool in
                    ToolButtonSettingsIcon(icon: tool)
                }
                
            }.padding()
        }
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(getBackgroundColor(colorScheme))
                .shadow(radius: 5)
        )
        
    }
    
}
