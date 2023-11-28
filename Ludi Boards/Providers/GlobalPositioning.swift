//
//  GlobalPositioning.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import Combine

class GlobalPositioningSystem: ObservableObject {
    // Properties to store screen size and safe area insets
    @Published var screenSize: CGSize = UIScreen.main.bounds.size
    @Published var safeAreaInsets: EdgeInsets = EdgeInsets()

    // Initialization
    init() {
        updateScreenSizeAndInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenSizeAndInsets), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func updateScreenSizeAndInsets() {
        if let window = UIApplication.shared.windows.first {
            DispatchQueue.main.async {
                self.screenSize = window.frame.size
                let uiInsets = window.safeAreaInsets
                self.safeAreaInsets = EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
            }
        }
    }

    // Function to get coordinates for specified area
    func getCoordinate(for area: ScreenArea) -> CGPoint {
        switch area {
        case .center:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        case .topRight:
            return CGPoint(x: screenSize.width - safeAreaInsets.trailing, y: safeAreaInsets.top)
        case .topLeft:
            return CGPoint(x: safeAreaInsets.leading, y: safeAreaInsets.top)
        case .bottomRight:
            return CGPoint(x: screenSize.width - safeAreaInsets.trailing, y: screenSize.height - safeAreaInsets.bottom)
        case .bottomLeft:
            return CGPoint(x: safeAreaInsets.leading, y: screenSize.height - safeAreaInsets.bottom)
        case .bottomCenter:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height - safeAreaInsets.bottom)
        case .topCenter:
            return CGPoint(x: screenSize.width / 2, y: safeAreaInsets.top)
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

struct GlobalPositioningZStack<Content: View>: View {
    let content: (GeometryProxy) -> Content

    init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle())
                .gesture(TapGesture().onEnded { _ in
                    print("Tapped anywhere on the screen")
                })
            ZStack {
                // Injecting the dynamic content
                content(geometry)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.clear) // Making the background clear
        }
    }
}

struct GlobalPositioningZStack_Previews: PreviewProvider {
    static var previews: some View {
        GlobalPositioningZStack { geo in
            
        }
    }
}
