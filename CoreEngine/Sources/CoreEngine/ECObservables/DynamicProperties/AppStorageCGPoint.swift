//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/9/24.
//

import Foundation
import SwiftUI
import CoreGraphics

@propertyWrapper
public struct AppStorageCGPoint: DynamicProperty {
    public var key: String
    public var defaultValue: CGPoint
    @AppStorage public var storedData: String

    public init(wrappedValue: CGPoint = .zero, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
        _storedData = AppStorage(wrappedValue: "", key)
        // Initialize the storage with the default value if it's not already set.
        if self.wrappedValue == .zero && defaultValue != .zero {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: CGPoint {
        get { storedData.toCGPoint() }
        set { storedData = newValue.toString() }
    }

    // Optionally, you can provide a 'projectedValue' if you need direct access to more complex behavior or additional data.
    public var projectedValue: AppStorageCGPoint {
        return self
    }
}

private extension String {
    func toCGPoint() -> CGPoint {
        let components = self.split(separator: ",").compactMap { Double($0) }
        guard components.count == 2 else { return .zero }
        return CGPoint(x: components[0], y: components[1])
    }
}

private extension CGPoint {
    func toString() -> String {
        return "\(self.x),\(self.y)"
    }
}
