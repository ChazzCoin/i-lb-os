//
//  GlobalPositioning.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import Combine

public class GlobalPositioningSystem: ObservableObject {
    // Properties to store screen size and safe area insets
    @State public var screenPaddingX: CGFloat = 50
    @State public var screenPaddingY: CGFloat = 25
    @Published public var screenSize: CGSize = UIScreen.main.bounds.size
    @Published public var safeAreaInsets: EdgeInsets = EdgeInsets()

    // Initialization
    public init() {
        updateScreenSizeAndInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenSizeAndInsets), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc public func updateScreenSizeAndInsets() {
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

    // Function to get coordinates for specified area
    public func getCoordinate(for area: ScreenArea) -> CGPoint {
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
    public func getCoordinate(for area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> CGPoint {
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
    public func getOffset(for area: ScreenArea) -> CGSize {
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

public enum ScreenArea {
    case center, topRight, topLeft, bottomRight, bottomLeft, bottomCenter, topCenter
}

public struct GlobalPositioningZStack<Content: View>: View {
    let content: (GeometryProxy, GlobalPositioningSystem) -> Content

    public init(@ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
    }

    @State var gps = GlobalPositioningSystem()
    
    public var body: some View {
        GeometryReader { geometry in
            content(geometry, gps)
        }.frame(maxWidth: gps.screenSize.width, maxHeight: gps.screenSize.height)
            .ignoresSafeArea(.all)
            .background(Color.clear)
    }
}


