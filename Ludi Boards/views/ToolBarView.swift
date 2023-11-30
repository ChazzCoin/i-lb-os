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
                
                ForEach(soccerTools, id: \.self) { tool in
                    ToolButtonIcon(icon: tool)
                }
                
                content.padding()
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth/2), height: 75)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        .position(x: gps.getCoordinate(for: .bottomLeft).x + (sWidth/2), y: gps.getCoordinate(for: .bottomLeft).y - 50)
        .padding(.horizontal)
        .zIndex(20.0)
    }
    
//    private func foregroundColorForScheme(_ scheme: ColorScheme) -> Color {
//        switch scheme {
//            case .light:
//                // Use a color suitable for light mode
//                return Color.black.opacity(0.8)
//            case .dark:
//                // Use a color suitable for dark mode
//                return Color.white.opacity(0.8)
//            @unknown default:
//                // Fallback for future color schemes
//                return Color.gray.opacity(0.8)
//            }
//    }
}


struct LineIconView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting point of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.5)

                // End point of the line
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.5)

                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(Color.primary, lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ToolBarPicker_Previews: PreviewProvider {
    static var previews: some View {
//        ToolBarPicker {
//            ToolButtonIcon(icon: SoccerToolProvider.dottedLine)
//        }
        LineIconView()
            .frame(width: 50, height: 50)
            .foregroundColor(.blue)
    }
}
