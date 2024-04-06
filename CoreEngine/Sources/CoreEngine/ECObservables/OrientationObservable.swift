//
//  OrientationInfo.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI

public class OrientationInfo: ObservableObject {
    @Published public var orientation: UIDeviceOrientation = .unknown

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc public func orientationChanged() {
        orientation = UIDevice.current.orientation
    }
}
