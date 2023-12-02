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
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 200, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        
    }
    
}


struct LineIconView: View {
    @Environment(\.colorScheme) var colorScheme
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
            .stroke(foregroundColorForScheme(colorScheme), lineWidth: 2)
        }
        .rotationEffect(Angle(degrees: 45))
        .aspectRatio(1, contentMode: .fit)
    }
}

struct DottedLineIconView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting and end points of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.5)
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.5)

                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(foregroundColorForScheme(colorScheme), style: StrokeStyle(lineWidth: 2, dash: [5]))
        }
        .rotationEffect(Angle(degrees: 45))
        .aspectRatio(1, contentMode: .fit)
    }

}


struct CurvedLineIconView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting point of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.9)

                // Control points for curve
                let control1 = CGPoint(x: width * 0.3, y: height * 0.1)
                let control2 = CGPoint(x: width * 0.7, y: height * 0.1)

                // End point of the line
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.9)

                path.move(to: startPoint)
                path.addCurve(to: endPoint, control1: control1, control2: control2)
            }
            .stroke(foregroundColorForScheme(colorScheme), lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


