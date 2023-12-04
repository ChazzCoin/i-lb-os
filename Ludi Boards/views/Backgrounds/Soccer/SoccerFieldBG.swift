//
//  SoccerFieldBG.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import SwiftUI

// YES
struct SoccerFieldFullView: View {
    
    let width: CGFloat
    let height: CGFloat
    let stroke: CGFloat
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                // Scale factors based on view size and standard field dimensions
                let lengthScale = width / 105
                let widthScale = height / 68
                
                // Outer boundary
                path.addRect(CGRect(x: 0, y: 0, width: width, height: height))
                
                // Center line
                path.move(to: CGPoint(x: width / 2, y: 0))
                path.addLine(to: CGPoint(x: width / 2, y: height))
                
                // Center circle
                path.addEllipse(in: CGRect(x: width / 2 - 9.15 * widthScale, y: height / 2 - 9.15 * widthScale, width: 18.3 * widthScale, height: 18.3 * widthScale))
                
                // Penalty areas
                let penaltyAreaWidth = 16.5 * lengthScale
                let penaltyAreaHeight = 40.3 * widthScale
                path.addRect(CGRect(x: 0, y: (height - penaltyAreaHeight) / 2, width: penaltyAreaWidth, height: penaltyAreaHeight))
                path.addRect(CGRect(x: width - penaltyAreaWidth, y: (height - penaltyAreaHeight) / 2, width: penaltyAreaWidth, height: penaltyAreaHeight))
                
                // Goal areas
                let goalAreaWidth = 5.5 * lengthScale
                let goalAreaHeight = 18.32 * widthScale
                path.addRect(CGRect(x: 0, y: (height - goalAreaHeight) / 2, width: goalAreaWidth, height: goalAreaHeight))
                path.addRect(CGRect(x: width - goalAreaWidth, y: (height - goalAreaHeight) / 2, width: goalAreaWidth, height: goalAreaHeight))
            }
            .stroke(color, lineWidth: stroke)
            .rotationEffect(.degrees(90))
        }.frame(width: width, height: height)
    }
}



struct SoccerFieldHalfView: View {
    
    let width: CGFloat
    let height: CGFloat
    let stroke: CGFloat
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                

                // Scale factors based on view size and half of the standard field dimensions
                let lengthScale = width / (105 / 2) // Half of the field length
                let widthScale = height / 68

                // Outer boundary of half field
                path.addRect(CGRect(x: 0, y: 0, width: width, height: height))


                // Center circle (only half visible)
                path.addArc(center: CGPoint(x: 0, y: height / 2), radius: 9.15 * widthScale, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: false)

                // Penalty area
                let penaltyAreaWidth = 16.5 * lengthScale
                let penaltyAreaHeight = 40.3 * widthScale
                path.addRect(CGRect(x: width - penaltyAreaWidth, y: (height - penaltyAreaHeight) / 2, width: penaltyAreaWidth, height: penaltyAreaHeight))
                
                // Goal area
                let goalAreaWidth = 5.5 * lengthScale
                let goalAreaHeight = 18.32 * widthScale
                path.addRect(CGRect(x: width - goalAreaWidth, y: (height - goalAreaHeight) / 2, width: goalAreaWidth, height: goalAreaHeight))
            }
            .stroke(color, lineWidth: stroke)
            .rotationEffect(.degrees(-90))
        }.frame(width: width, height: height)
    }
}

struct BasicSquareView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = 4000 * 0.8
                let height: CGFloat = 3000

                // Outer boundary of half field
                path.addRect(CGRect(x: 0, y: 0, width: width, height: height))
            }
            .stroke(Color.green, lineWidth: 10)
            .rotationEffect(.degrees(-90))
        }.frame(width: 4000 * 0.8, height: 3000)
    }
}


struct SoccerFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SoccerFieldHalfView(width: 3000.0, height: 4000.0, stroke: 2, color: Color.white)
    }
}
