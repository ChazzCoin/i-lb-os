//
//  ToolBarView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/29/23.
//

import Foundation
import SwiftUI

// Single Icon
public struct ToolButtonIcon: View {
    public var icon: CoreTool // Assuming IconProvider conforms to SwiftUI's View

    @State public var isLocked = false
    
    public init(icon: CoreTool, isLocked: Bool = false) {
        self.icon = icon
        self.isLocked = isLocked
    }

    public var body: some View {
        Image(icon.managedTool.image)
            .resizable()
            .frame(width: 40, height: 40)
            .onDrag {
                return NSItemProvider(object: icon.managedTool.title as NSString)
            }
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.managedTool)")
                CodiChannel.TOOL_ON_CREATE.send(value: icon.managedTool)
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}


// Picker Bar
public struct ToolBarPicker<Content: View>: View {
    public let content: Content
    @AppStorage("toolBarIsShowing") public var toolBarIsShowing: Bool = false
    @Environment(\.colorScheme) public var colorScheme
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public let soccerTools = SoccerToolProvider.allCases
    
    @State public var gps = GlobalPositioningSystem(CoreNameSpace.local)
    
    public var sWidth = UIScreen.main.bounds.width
    public var sHeight = UIScreen.main.bounds.height

    public var body: some View {
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
                        ToolButtonIcon(icon: SoccerToolProvider(subType: tool))
                    }
                }
                
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 75)
        .solBackground()
        
    }
    
}





