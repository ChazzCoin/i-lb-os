//
//  FootballFieldView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import SwiftUI

struct FootballFieldView: View {
    var body: some View {
        GeometryReader { geometry in
            let fieldWidth = 4000.0
            let fieldHeight = 3000.0
            
            
            // Scale factors based on view size and field dimensions
            let yardLineScale = fieldHeight / 120.0

            ZStack {
                
                // Draw the outer boundary of the field
                Rectangle()
                    .stroke(Color.black, lineWidth: 3)
                // Draw the yard lines
                ForEach(0..<11) { marker in
                    Path { path in
                        let yPosition = CGFloat(marker) * 10.0 * yardLineScale
                        path.move(to: CGPoint(x: 0, y: yPosition))
                        path.addLine(to: CGPoint(x: fieldWidth, y: yPosition))
                    }
                    .stroke(marker % 5 == 0 ? Color.black : Color.gray, lineWidth: marker % 5 == 0 ? 2 : 1)
                }

                // Add yard markers
                ForEach(0..<11) { marker in
                    if marker != 0 && marker != 10 { // Exclude end zones
                        Text("\(marker * 10)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .position(x: fieldWidth / 2, y: CGFloat(marker) * 10.0 * yardLineScale)
                    }
                }
            }
        }.frame(width: 4000, height: 3000)
    }
}

struct FootballFieldView_Previews: PreviewProvider {
    static var previews: some View {
        FootballFieldView()
    }
}
