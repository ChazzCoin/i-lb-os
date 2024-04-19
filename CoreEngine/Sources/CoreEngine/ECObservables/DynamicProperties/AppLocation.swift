//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

@propertyWrapper
public struct AppLocation: DynamicProperty {
    @ObservedObject public var locationManager: CoreLocationManager
    public init() {
        locationManager = CoreLocationManager()
    }
    public var wrappedValue: CLLocation? { locationManager.location }
    public var projectedValue: CoreLocationManager { locationManager }
    public func update() { locationManager.requestLocation() }
}

public class CoreLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    public let manager = CLLocationManager()
    @Published public var location: CLLocation?

    public override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    public func requestLocation() {
        manager.requestLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
