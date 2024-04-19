//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/14/24.
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper
public struct AppLifecycle: DynamicProperty {
    // The property that the wrapper modifies
    @State public var isActive: Bool = false
    @State public var onChange: () -> Void = { }

    // Combine cancellables to store the subscription
    public var cancellables = Set<AnyCancellable>()

    // The notification to observe
    public var broadcastEvent: BroadcastEvents

    // The wrappedValue is what the property wrapper exposes
    public var wrappedValue: Bool {
        get { 
            print("ISACTIVE: \(isActive)")
            onChange()
            return isActive
        }
        set {
            isActive = newValue
            if newValue { onChange() }
        }
    }

    // This allows access to the property wrapper itself via `$`
    public var projectedValue: AppLifecycle {
        return self
    }

    // Initialization with specific notification name
    public init(_ broadcastEventName: BroadcastEvents) {
        self.broadcastEvent = broadcastEventName
        // Subscribe to specified notification
        NotificationCenter.default.publisher(for: broadcastEventName.notificationName)
            .map { _ in true }
            .assign(to: \.isActive, on: self)
            .store(in: &cancellables)
    }

    // DynamicProperty requires a way to update the view, update() is called to recompute the view body
    mutating public func update() {
        // This is required to conform to the DynamicProperty protocol
        // It's where SwiftUI can trigger a re-evaluation of the body
        _isActive.update()
    }
    
}
