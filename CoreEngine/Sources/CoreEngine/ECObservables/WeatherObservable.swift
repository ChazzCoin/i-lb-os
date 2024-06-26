//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import WeatherKit
import CoreLocation
import Combine

@available(iOS 17.0, *)
@Observable class WeatherManager {
    private let weatherService = WeatherService()
    var weather: Weather?
    
    func getWeather(lat: Double, long: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) { [weak self] in
                return try await self?.weatherService.weather(for: .init(latitude: lat, longitude: long))
            }.value
            
        } catch {
            print("Failed to get weather data. \(error)")
        }
    }

    var icon: String {
        guard let iconName = weather?.currentWeather.symbolName else { return "--" }
        return iconName
    }
    
    var temperature: String {
        guard let temp = weather?.currentWeather.temperature else { return "--" }
        let convert = temp.converted(to: .celsius).value
        return String(Int(convert)) + "°C"
    }
    
    var humidity: String {
        guard let humidity = weather?.currentWeather.humidity else { return "--" }
        let computedHumidity = humidity * 100
        return String(Int(computedHumidity)) + "%"
    }
}
