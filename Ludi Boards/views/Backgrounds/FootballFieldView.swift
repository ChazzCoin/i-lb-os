//
//  FootballFieldView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import SwiftUI

struct FootballFieldView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    let isMini: Bool
    
    var body: some View {
        GeometryReader { geometry in
            
            let fieldHeight = isMini ? 100.0 : self.BEO.boardHeight
            let fieldWidth = isMini ? 100.0 : self.BEO.boardWidth

            ZStack {
                // Draw and fill the endzones
                Path { path in
                    let endZoneWidth = fieldHeight / 12 // 10 yards out of 120
                    path.addRect(CGRect(x: 0, y: 0, width: fieldWidth, height: endZoneWidth))
                    path.addRect(CGRect(x: 0, y: fieldHeight - endZoneWidth, width: fieldWidth, height: endZoneWidth))
                }
                .fill(isMini ? Color.white : Color.red.opacity(0.75)) // Choose your desired color for the endzones

                // Draw the field lines
                Path { path in
                    // Draw the outline of the field
                    path.addRect(CGRect(x: 0, y: 0, width: fieldWidth, height: fieldHeight))

                    // Draw the yard lines
                    let endZoneWidth = fieldHeight / 12
                    let yardLineSpacing = (fieldHeight - 2 * endZoneWidth) / 10
                    for i in 1...9 {
                        let y = endZoneWidth + CGFloat(i) * yardLineSpacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: fieldWidth, y: y))
                    }
                }
                .stroke(isMini ? Color.white : self.BEO.boardFieldLineColor, lineWidth: isMini ? 3.0 : self.BEO.boardFeildLineStroke)
            }
            
        }
        .frame(width: isMini ? 100.0 : self.BEO.boardWidth, height: isMini ? 100.0 : self.BEO.boardHeight)
    }
}

struct FootballFieldView2: View {
    
    var body: some View {
        GeometryReader { geometry in
            let fieldWidth = geometry.size.width
            let fieldHeight = fieldWidth * (120 / 53.3) // Keeping the aspect ratio

            Path { path in
                // Draw the outline of the field
                path.addRect(CGRect(x: 0, y: 0, width: fieldWidth, height: fieldHeight))

                // Draw the end zones
                let endZoneWidth = fieldHeight / 12 // 10 yards out of 120
                path.addRect(CGRect(x: 0, y: 0, width: fieldWidth, height: endZoneWidth))
                path.addRect(CGRect(x: 0, y: fieldHeight - endZoneWidth, width: fieldWidth, height: endZoneWidth))

                // Draw the yard lines
                let yardLineSpacing = (fieldHeight - 2 * endZoneWidth) / 10
                for i in 1...9 {
                    let y = endZoneWidth + CGFloat(i) * yardLineSpacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: fieldWidth, y: y))
                }
            }
            .stroke(Color.black, lineWidth: 10)
        }
    }
}
