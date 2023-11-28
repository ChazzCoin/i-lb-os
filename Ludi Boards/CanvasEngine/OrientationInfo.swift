//
//  OrientationInfo.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI

class OrientationInfo: ObservableObject {
    @Published var orientation: UIDeviceOrientation = .unknown

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func orientationChanged() {
        orientation = UIDevice.current.orientation
    }
}

/**
 struct ContentView: View {
     @StateObject private var orientationInfo = OrientationInfo()

     var body: some View {
         Group {
             switch orientationInfo.orientation {
             case .landscapeLeft, .landscapeRight:
                 // Landscape View
             case .portrait, .portraitUpsideDown:
                 // Portrait View
             default:
                 // Default View
             }
         }
     }
 }
 
 */
