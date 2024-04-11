//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import SwiftUI
import Network

public class NetworkMonitor: ObservableObject {
    
    public static func checkInternetConnection(_ completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                completion(isConnected)
            }
            monitor.cancel()
        }
    }
    
    @AppStorage("isConnected") public var isConnected: Bool = false
    public var monitor: NWPathMonitor?
    
    public init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    public func startMonitoring() {
        guard let monitor = monitor else { return }
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        stopMonitoring()
    }
    
    public func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}
