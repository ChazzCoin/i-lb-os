//
//  RecordShapeView.swift
//  Wrlds
//
//  Created by Charles Romeo on 1/10/24.
//

import Foundation
import SwiftUI

struct RecordShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Outer circle (record's main body)
        path.addEllipse(in: rect)

        // Inner circle (record's label)
        let innerCircleRadius = rect.width / 4
        let innerCircleRect = CGRect(
            x: rect.midX - innerCircleRadius / 2,
            y: rect.midY - innerCircleRadius / 2,
            width: innerCircleRadius,
            height: innerCircleRadius
        )
        path.addEllipse(in: innerCircleRect)

        // Smallest circle (record's center hole)
        let centerCircleRadius = innerCircleRadius / 4
        let centerCircleRect = CGRect(
            x: rect.midX - centerCircleRadius / 2,
            y: rect.midY - centerCircleRadius / 2,
            width: centerCircleRadius,
            height: centerCircleRadius
        )
        path.addEllipse(in: centerCircleRect)

        return path
    }
}

#Preview {
    RecordShape()
        .stroke(Color.black, lineWidth: 1)
        .frame(width: 100, height: 100)
        .background(Color.gray.opacity(0.0))
        .padding(50) // Adjust padding as needed
}



