//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/7/24.
//

import Foundation
import SwiftUI


public extension View {
    
    func enableManagedViewBasic(viewId: String, activityId: String="", bounds: CGRect?=nil) -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, activityId: activityId, bounds: bounds))
    }
    
}


public struct WithinScreenBoundsModifier: ViewModifier {
    @Binding public var offset: CGSize
    public let viewSize: CGSize
    
    public func body(content: Content) -> some View {
        content
//            .offset(offset)
            .onAppear(perform: adjustPositionIfNeeded)
            .onChange(of: offset) { _ in adjustPositionIfNeeded() }
            .onChange(of: viewSize) { _ in adjustPositionIfNeeded() }
    }
    
    public func adjustPositionIfNeeded() {
        let screenSize = UIScreen.main.bounds.size
        let halfWidth = viewSize.width / 2
        let halfHeight = viewSize.height / 2
        
        let topRightX = offset.width - halfWidth

        // Calculate the boundaries of the view based on its center point
        var newOffset = offset
        let leftEdge = newOffset.width - halfWidth
        let rightEdge = newOffset.width + halfWidth
        let topEdge = newOffset.height - halfHeight
        let bottomEdge = newOffset.height + halfHeight

        // Adjust the offset to prevent the view from going out of bounds
        if leftEdge < 0 {
            newOffset.width = halfWidth
        } else if rightEdge > screenSize.width {
            newOffset.width = screenSize.width - halfWidth
        }

        if topEdge < 0 {
            newOffset.height = halfHeight
        } else if bottomEdge > screenSize.height {
            newOffset.height = screenSize.height - halfHeight
        }

        // Update the state in a SwiftUI-friendly way
        DispatchQueue.main.async {
            self.offset = newOffset  // Only update the state asynchronously if necessary
        }
    }
}

public extension View {
    func withinScreenBounds(offset: Binding<CGSize>, viewSize: CGSize) -> some View {
        modifier(WithinScreenBoundsModifier(offset: offset, viewSize: viewSize))
    }
}
