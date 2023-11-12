//
//  Draggable.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI

struct DraggableRectangleView: View {
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            // Update position continuously during the drag
            .position(x: position.x + (isDragging ? dragOffset.width : 0),
                      y: position.y + (isDragging ? dragOffset.height : 0))
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        self.isDragging = true
                    }
                    .sequenced(before: DragGesture())
                    .updating($dragOffset, body: { (value, state, transaction) in
                        switch value {
                        case .second(true, let drag):
                            state = drag?.translation ?? .zero
                        default:
                            break
                        }
                    })
                    .onEnded { value in
                        if case .second(true, let drag?) = value {
                            // Update the final position when the drag ends
                            self.position = CGPoint(x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                            self.isDragging = false
                        }
                    }
            )
            .opacity(isDragging ? 0.5 : 1)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
