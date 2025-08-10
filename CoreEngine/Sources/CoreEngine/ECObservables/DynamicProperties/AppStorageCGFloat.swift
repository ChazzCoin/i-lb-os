//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/10/24.
//

import Foundation
import SwiftUI
import CoreGraphics

@propertyWrapper
public struct AppStorageCGFloat: DynamicProperty {
    public var key: String
    public var defaultValue: CGFloat
    @AppStorage public var storedData: String

    public init(wrappedValue: CGFloat = 0.0, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
        _storedData = AppStorage(wrappedValue: "", key)
        // Initialize the storage with the default value if it's not already set.
        if self.wrappedValue == 0.0 && defaultValue != 0.0 {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: CGFloat {
        get { storedData.toCGFloat() }
        set { storedData = newValue.toString() }
    }

    // Optionally, you can provide a 'projectedValue' if you need direct access to more complex behavior or additional data.
    public var projectedValue: AppStorageCGFloat {
        return self
    }
}

private extension String {
    func toCGFloat() -> CGFloat {
        return CGFloat(Double(self) ?? 0.0)
    }
}

private extension CGFloat {
    func toString() -> String {
        return "\(self)"
    }
}
