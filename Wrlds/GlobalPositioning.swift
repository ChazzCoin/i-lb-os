//
//  GlobalPositioning.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import Combine
import CoreEngine

class WorldsGlobalPositioningSystem: ObservableObject {
    // Properties to store screen size and safe area insets
    @State var screenPaddingX: CGFloat = 50
    @State var screenPaddingY: CGFloat = 25
    @Published var screenSize: CGSize = UIScreen.main.bounds.size
    @Published var safeAreaInsets: EdgeInsets = EdgeInsets()

    // Initialization
    init() {
        updateScreenSizeAndInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenSizeAndInsets), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func updateScreenSizeAndInsets() {
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        if let temp = scene as? UIWindowScene {
            if let w = temp.windows.first {
                DispatchQueue.main.async {
                    self.screenSize = w.frame.size
                    let uiInsets = w.safeAreaInsets
                    self.safeAreaInsets = EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
                }
            }
        }
    }
    
    var availableScreenRect: CGRect {
        CGRect(
            x: safeAreaInsets.leading + screenPaddingX,
            y: safeAreaInsets.top + screenPaddingY,
            width: screenSize.width - safeAreaInsets.leading - safeAreaInsets.trailing - (screenPaddingX * 2),
            height: screenSize.height - safeAreaInsets.top - safeAreaInsets.bottom - (screenPaddingY * 2)
        )
    }


    // Function to get coordinates for specified area
    func getCoordinate(for area: ScreenArea) -> CGPoint {
        switch area {
            case .center:
                return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            case .topRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX, y: safeAreaInsets.top + screenPaddingY)
            case .topLeft:
                return CGPoint(x: safeAreaInsets.leading, y: safeAreaInsets.top + screenPaddingY)
            case .bottomRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX, y: screenSize.height - safeAreaInsets.bottom - screenPaddingY)
            case .bottomLeft:
                return CGPoint(x: safeAreaInsets.leading, y: screenSize.height - safeAreaInsets.bottom)
            case .bottomCenter:
                return CGPoint(x: screenSize.width / 2, y: screenSize.height - safeAreaInsets.bottom)
            case .topCenter:
                return CGPoint(x: screenSize.width / 2, y: screenPaddingY)
        }
    }
    
    // Function to get coordinates for specified area with an optional offset
    func getCoordinate(for area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> CGPoint {
        switch area {
            case .center:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: (screenSize.height / 2) + offsetY)
            case .topRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX - offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
            case .topLeft:
                return CGPoint(x: safeAreaInsets.leading + offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
            case .bottomRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX - offsetX, y: screenSize.height - safeAreaInsets.bottom - screenPaddingY - offsetY)
            case .bottomLeft:
                return CGPoint(x: safeAreaInsets.leading + offsetX, y: screenSize.height - safeAreaInsets.bottom - offsetY)
            case .bottomCenter:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: screenSize.height - safeAreaInsets.bottom - offsetY)
            case .topCenter:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
        }
    }

    
    // Function to get offsets for specified area as CGSize
    func getOffset(for area: ScreenArea) -> CGSize {
        switch area {
        case .center:
            return CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
        case .topRight:
            return CGSize(width: screenSize.width - safeAreaInsets.trailing, height: safeAreaInsets.top)
        case .topLeft:
            return CGSize(width: safeAreaInsets.leading, height: safeAreaInsets.top)
        case .bottomRight:
            return CGSize(width: screenSize.width - safeAreaInsets.trailing, height: screenSize.height - safeAreaInsets.bottom)
        case .bottomLeft:
            return CGSize(width: safeAreaInsets.leading, height: screenSize.height - safeAreaInsets.bottom)
        case .bottomCenter:
            return CGSize(width: screenSize.width / 2, height: screenSize.height - safeAreaInsets.bottom)
        case .topCenter:
            return CGSize(width: screenSize.width / 2, height: safeAreaInsets.top)
        }
    }
}

enum ScreenArea {
    case center, topRight, topLeft, bottomRight, bottomLeft, bottomCenter, topCenter
}

extension CGRect {
    func locked(to bounds: CGRect) -> CGRect {
        var newRect = self
        if newRect.minX < bounds.minX { newRect.origin.x = bounds.minX }
        if newRect.maxX > bounds.maxX { newRect.origin.x = bounds.maxX - newRect.width }
        if newRect.minY < bounds.minY { newRect.origin.y = bounds.minY }
        if newRect.maxY > bounds.maxY { newRect.origin.y = bounds.maxY - newRect.height }
        return newRect
    }
    
    func isCompletelyWithin(_ bounds: CGRect) -> Bool {
       return bounds.contains(self)
    }
   func isPartiallyWithin(_ bounds: CGRect) -> Bool {
       return self.intersects(bounds)
   }
}
struct LockToScreenModifier: ViewModifier {
    @ObservedObject var gps: WorldsGlobalPositioningSystem
    @Binding var position: CGPoint
    var size: CGSize

    func body(content: Content) -> some View {
        content
            .position(position)
            .onChange(of: position) { newValue in
                // Clamp position if moved out of bounds
                let frame = CGRect(origin: CGPoint(x: newValue.x - size.width/2, y: newValue.y - size.height/2), size: size)
                let lockedFrame = frame.locked(to: gps.availableScreenRect)
                let center = CGPoint(x: lockedFrame.midX, y: lockedFrame.midY)
                if center != position {
                    DispatchQueue.main.async {
                        self.position = center
                        
                        
                    }
                }
            }
    }
}
