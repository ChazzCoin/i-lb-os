//
//  LineIcons.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/1/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct LineIconView: View {
    @State var isBgColor: Bool
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
            .stroke(isBgColor ? getBackgroundColor(colorScheme) : getForegroundColor(colorScheme), lineWidth: 2)
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
            .stroke(getForegroundColor(colorScheme), style: StrokeStyle(lineWidth: 2, dash: [5]))
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
            .stroke(getForegroundColor(colorScheme), lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
