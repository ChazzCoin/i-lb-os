//
//  DragAndDrop.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

struct lbDragger : ViewModifier {
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
            content
                .position(x: position.x + (isDragging ? dragOffset.width : 0),
                          y: position.y + (isDragging ? dragOffset.height : 0))
                .gesture(
                    LongPressGesture(minimumDuration: 0.01)
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
                                self.position = CGPoint(x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                                print("!!!! X: [ \(self.position.x) ] Y: [ \(self.position.y) ]")
                                self.isDragging = false
                            }
                        }
                )
                .opacity(isDragging ? 0.5 : 1)
        }
}
