//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/26/24.
//

import Foundation
import SwiftUI


public struct DraggableCornerModifier: ViewModifier {
    @Binding public var point: CGPoint

    public func body(content: Content) -> some View {
        draggableCorner(at: $point)
    }
    
    private func draggableCorner(at position: Binding<CGPoint>) -> some View {
        Circle()
            .frame(width: 200, height: 200)
            .foregroundColor(.green)
            .position(position.wrappedValue)
            .gesture(DragGesture().onChanged { value in
                position.wrappedValue = value.location
            })
    }
}

@ViewBuilder
public func DragAnchor(at position: Binding<CGPoint>, width: Double = 100, height: Double = 100, onChanged: @escaping () -> Void = {}) -> some View {
    Circle()
        .frame(width: width, height: height)
        .foregroundColor(.green)
        .position(position.wrappedValue)
        .gesture(DragGesture().onChanged { value in
            position.wrappedValue = value.location
            onChanged()
        })
}
@ViewBuilder
public func DragAnchor(x: Binding<CGFloat>, y: Binding<CGFloat>, width: Double = 100, height: Double = 100, onChanged: @escaping () -> Void = {}) -> some View {
    Circle()
        .frame(width: width, height: height)
        .foregroundColor(.green)
        .position(x: x.wrappedValue, y: y.wrappedValue)
        .gesture(DragGesture().onChanged { value in
            x.wrappedValue = value.location.x
            y.wrappedValue = value.location.y
            onChanged()
        })
}
//@ViewBuilder
//public func DragAnchor(x: Binding<Double>, y: Binding<Double>) -> some View {
//    Circle()
//        .frame(width: 200, height: 200)
//        .foregroundColor(.green)
//        .position(x: x.wrappedValue, y: y.wrappedValue)
//        .gesture(DragGesture().onChanged { value in
//            x.wrappedValue = value.location.x
//            y.wrappedValue = value.location.y
//        })
//}

public extension View {
    
    func dragAnchor(point: Binding<CGPoint>) -> some View {
        modifier(DraggableCornerModifier(point: point))
    }
    
    func draggable() -> some View {
        modifier(FreeDraggableModifier())
    }
   
    func draggable(
        position: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void,
        onEnded: @escaping () -> Void
    ) -> some View {
        self.modifier(DraggableModifier(
            position: position,
            isDragging: isDragging,
            onChanged: onChanged,
            onEnded: onEnded
        ))
    }
    
    func draggable(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void,
        onEnded: @escaping () -> Void
    ) -> some View {
        self.modifier(DualPointDraggableModifier(
            position1: position1,
            position2: position2,
            isDragging: isDragging,
            onChanged: onChanged,
            onEnded: onEnded
        ))
    }
    
    func draggable(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        position3: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void,
        onEnded: @escaping () -> Void
    ) -> some View {
        self.modifier(TriplePointDraggableModifier(
            position1: position1,
            position2: position2,
            position3: position3,
            isDragging: isDragging,
            onChanged: onChanged,
            onEnded: onEnded
        ))
    }
    
    func draggable(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        position3: Binding<CGPoint>,
        position4: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void,
        onEnded: @escaping () -> Void
    ) -> some View {
        self.modifier(QuadPointDraggableModifier(
            position1: position1,
            position2: position2,
            position3: position3,
            position4: position4,
            isDragging: isDragging,
            onChanged: onChanged,
            onEnded: onEnded
        ))
    }
}


public struct FreeDraggableModifier: ViewModifier {
    
    public init() {}
    
    @State public var position: CGPoint = CGPoint(x: 300, y: 300)
    @State public var isDragging: Bool = false
    @State public var originalPosition: CGPoint = .zero

    public func body(content: Content) -> some View {
        content
            .position(position)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        if !isDragging {
                            originalPosition = position
                        }
                        let translation = drag.translation
                        position = CGPoint(x: originalPosition.x + translation.width,
                                           y: originalPosition.y + translation.height)
                    }
                    .onEnded { drag in
                        isDragging = false
                        let translation = drag.translation
                        position = CGPoint(x: originalPosition.x + translation.width,
                                           y: originalPosition.y + translation.height)
                    }
            )
    }
}


public struct DraggableModifier: ViewModifier {
    
    public init(
        position: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void = {},
        onEnded: @escaping () -> Void = {}
    ) {
        self._position = position
        self.originalPosition = position.wrappedValue
        self._isDragging = isDragging
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    @Binding public var position: CGPoint
    @Binding public var isDragging: Bool
    @State public var originalPosition: CGPoint = .zero
    public var onChanged: () -> Void
    public var onEnded: () -> Void

    public func body(content: Content) -> some View {
        content
            
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        if !isDragging {
                            originalPosition = position
                        }
                        let translation = drag.translation
                        position = CGPoint(x: originalPosition.x + translation.width,
                                           y: originalPosition.y + translation.height)
                        onChanged()
                    }
                    .onEnded { drag in
                        isDragging = false
                        let translation = drag.translation
                        position = CGPoint(x: originalPosition.x + translation.width,
                                           y: originalPosition.y + translation.height)
                        onEnded()
                    }
            )
    }
}

public struct DualPointDraggableModifier: ViewModifier {
    
    public init(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void = {},
        onEnded: @escaping () -> Void = {}
    ) {
        self._position1 = position1
        self.originalPosition1 = position1.wrappedValue
        self._position2 = position2
        self.originalPosition2 = position2.wrappedValue
        self._isDragging = isDragging
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    @Binding public var position1: CGPoint
    @Binding public var position2: CGPoint
    @Binding public var isDragging: Bool
    @State public var originalPosition1: CGPoint = .zero
    @State public var originalPosition2: CGPoint = .zero
    public var onChanged: () -> Void
    public var onEnded: () -> Void

    @State public var useOriginal = false
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        if useOriginal {
                            originalPosition1 = position1
                            originalPosition2 = position2
                            useOriginal = false
                        }
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        onChanged()
                    }
                    .onEnded { drag in
                        isDragging = false
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        useOriginal = true
                        onEnded()
                    }
            )
    }
}


public struct TriplePointDraggableModifier: ViewModifier {
    
    public init(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        position3: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void = {},
        onEnded: @escaping () -> Void = {}
    ) {
        self._position1 = position1
        self.originalPosition1 = position1.wrappedValue
        self._position2 = position2
        self.originalPosition2 = position2.wrappedValue
        self._position3 = position3
        self.originalPosition3 = position3.wrappedValue
        self._isDragging = isDragging
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    @Binding public var position1: CGPoint
    @Binding public var position2: CGPoint
    @Binding public var position3: CGPoint
    @Binding public var isDragging: Bool
    @State public var originalPosition1: CGPoint = .zero
    @State public var originalPosition2: CGPoint = .zero
    @State public var originalPosition3: CGPoint = .zero
    public var onChanged: () -> Void
    public var onEnded: () -> Void

    @State public var useOriginal = false
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        if useOriginal {
                            originalPosition1 = position1
                            originalPosition2 = position2
                            originalPosition3 = position3
                            useOriginal = false
                        }
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        position3 = CGPoint(x: originalPosition3.x + translation.width,
                                           y: originalPosition3.y + translation.height)
                        onChanged()
                    }
                    .onEnded { drag in
                        isDragging = false
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        position3 = CGPoint(x: originalPosition3.x + translation.width,
                                           y: originalPosition3.y + translation.height)
                        useOriginal = true
                        onEnded()
                    }
            )
    }
}


public struct QuadPointDraggableModifier: ViewModifier {
    
    public init(
        position1: Binding<CGPoint>,
        position2: Binding<CGPoint>,
        position3: Binding<CGPoint>,
        position4: Binding<CGPoint>,
        isDragging: Binding<Bool>,
        onChanged: @escaping () -> Void = {},
        onEnded: @escaping () -> Void = {}
    ) {
        self._position1 = position1
        self.originalPosition1 = position1.wrappedValue
        self._position2 = position2
        self.originalPosition2 = position2.wrappedValue
        self._position3 = position3
        self.originalPosition3 = position3.wrappedValue
        self._position4 = position4
        self.originalPosition4 = position4.wrappedValue
        self._isDragging = isDragging
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    @Binding public var position1: CGPoint
    @Binding public var position2: CGPoint
    @Binding public var position3: CGPoint
    @Binding public var position4: CGPoint
    @Binding public var isDragging: Bool
    @State public var originalPosition1: CGPoint = .zero
    @State public var originalPosition2: CGPoint = .zero
    @State public var originalPosition3: CGPoint = .zero
    @State public var originalPosition4: CGPoint = .zero
    public var onChanged: () -> Void
    public var onEnded: () -> Void

    @State public var useOriginal = false
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        if useOriginal {
                            originalPosition1 = position1
                            originalPosition2 = position2
                            originalPosition3 = position3
                            originalPosition4 = position4
                            useOriginal = false
                        }
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        position3 = CGPoint(x: originalPosition3.x + translation.width,
                                           y: originalPosition3.y + translation.height)
                        position4 = CGPoint(x: originalPosition4.x + translation.width,
                                           y: originalPosition4.y + translation.height)
                        onChanged()
                    }
                    .onEnded { drag in
                        isDragging = false
                        let translation = drag.translation
                        position1 = CGPoint(x: originalPosition1.x + translation.width,
                                           y: originalPosition1.y + translation.height)
                        position2 = CGPoint(x: originalPosition2.x + translation.width,
                                           y: originalPosition2.y + translation.height)
                        position3 = CGPoint(x: originalPosition3.x + translation.width,
                                           y: originalPosition3.y + translation.height)
                        position4 = CGPoint(x: originalPosition4.x + translation.width,
                                           y: originalPosition4.y + translation.height)
                        useOriginal = true
                        onEnded()
                    }
            )
    }
}
