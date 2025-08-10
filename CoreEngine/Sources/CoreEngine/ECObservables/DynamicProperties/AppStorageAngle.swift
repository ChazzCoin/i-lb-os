//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/10/24.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct AppStorageAngle: DynamicProperty {
    public var key: String
    public var defaultValue: Angle
    @AppStorage public var storedData: String

    public init(wrappedValue: Angle = .zero, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
        _storedData = AppStorage(wrappedValue: "", key)
        // Initialize the storage with the default value if it's not already set.
        if self.wrappedValue == .zero && defaultValue != .zero {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: Angle {
        get { storedData.toAngle() }
        set { storedData = newValue.toString() }
    }

    // Optionally, you can provide a 'projectedValue' if you need direct access to more complex behavior or additional data.
    public var projectedValue: AppStorageAngle {
        return self
    }
}

private extension String {
    func toAngle() -> Angle {
        guard let degrees = Double(self) else { return .zero }
        return Angle(degrees: degrees)
    }
}

private extension Angle {
    func toString() -> String {
        return "\(self.degrees)"
    }
}
