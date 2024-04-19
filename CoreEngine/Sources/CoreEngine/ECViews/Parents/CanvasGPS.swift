//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

public class CanvasGPS {
    private var width: CGFloat
    private var height: CGFloat

    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }

    // Center
    public func center() -> CGPoint { return CGPoint(x: width / 2, y: height / 2) }
    public func topLeft() -> CGPoint { return CGPoint(x: 0, y: 0) }
    public func topCenter() -> CGPoint { return CGPoint(x: width / 2, y: 0) }
    public func topRight() -> CGPoint { return CGPoint(x: width, y: 0) }
    public func bottomLeft() -> CGPoint { return CGPoint(x: 0, y: height) }
    public func bottomCenter() -> CGPoint { return CGPoint(x: width / 2, y: height) }
    public func bottomRight() -> CGPoint { return CGPoint(x: width, y: height) }
    public func leftCenter() -> CGPoint { return CGPoint(x: 0, y: height / 2) }
    public func rightCenter() -> CGPoint { return CGPoint(x: width, y: height / 2) }

    public func positionForArea(_ area: CanvasArea) -> CGPoint {
        switch area {
            case .center:
                return center()
            case .topRight:
                return topRight()
            case .topLeft:
                return topLeft()
            case .bottomRight:
                return bottomRight()
            case .bottomLeft:
                return bottomLeft()
            case .bottomCenter:
                return bottomCenter()
            case .topCenter:
                return topCenter()
        }
    }
    
    // Updating container size
    public func updateSize(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}

public enum CanvasArea {
    case center, topRight, topLeft, bottomRight, bottomLeft, bottomCenter, topCenter
}

public extension View {
    // Method to set the position of the view based on a specified ScreenArea
    func position(using gps: CanvasGPS, at area: CanvasArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> some View {
        self.position(gps.positionForArea(area))
    }

    // Method to set the offset of the view based on a specified ScreenArea
    func offset(using gps: CanvasGPS, for area: CanvasArea) -> some View {
        let offsetSize = gps.positionForArea(area)
        return self.offset(x: offsetSize.x, y: offsetSize.y)
    }
}

public struct CanvasPositioningZStack<Content: View>: View {
    let content: (CanvasGPS) -> Content
    @State var gps: CanvasGPS
    
    @State var width: CGFloat = 20000
    @State var height: CGFloat = 20000
    
    public init(width: CGFloat = 20000, height: CGFloat = 20000, @ViewBuilder content: @escaping (CanvasGPS) -> Content) {
        self.content = content
        self.gps = CanvasGPS(width: width, height: height)
        self.width = width
        self.height = height
    }

    public var body: some View {
        ZStack() {
            content(gps)
        }
        .zIndex(1.0)
        .frame(width: width, height: height)
    }
}

public func CanvasView(@ViewBuilder _ content: @escaping () -> some View) -> some View {
    ZStack() {
        content()
    }
    .zIndex(1.0)
    .frame(width: 20000, height: 20000)
}
