//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/26/24.
//

import Foundation
import SwiftUI

public struct ResizableRectangleV2: View {
    
    public init() {}
    
    @State public var topLeft = CGPoint(x: 100, y: 100)
    @State public var bottomRight = CGPoint(x: 500, y: 500)
    @State public var isDragging = false
    @State public var dragOffset = CGSize.zero

    public var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .path(in: CGRect(x: min(topLeft.x, bottomRight.x),
                                 y: min(topLeft.y, bottomRight.y),
                                 width: abs(bottomRight.x - topLeft.x),
                                 height: abs(bottomRight.y - topLeft.y)))
                .stroke(Color.red, lineWidth: 50)
                .draggable(
                    position1: $topLeft,
                    position2: $bottomRight,
                    isDragging: $isDragging,
                    onChanged: {
                        
                    }, onEnded: {
                        
                    })
            if !isDragging {
                HandleViewV2(position: $topLeft)
                HandleViewV2(position: $bottomRight)
            }
        }
    }

    public var doubleTapToToggleMode: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                isDragging.toggle()
            }
    }
}

public struct HandleViewV2: View {
    @Binding public var position: CGPoint
    public var body: some View {
        Circle()
            .frame(width: 200, height: 200)
            .foregroundColor(.red)
            .position(x: position.x, y: position.y)
            .highPriorityGesture(DragGesture()
                .onChanged { value in
                    self.position = value.location
                })
    }
}
