//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/14/24.
//

import Foundation
import SwiftUI
import Combine

public var globalCancellables = Set<AnyCancellable>()

public class BroadcastTools: ObservableObject {
    
    @Published public var ignoreRequest: Bool = false
    @Published public var cancellables = Set<AnyCancellable>()
    
    // MARK: -> System Channels
    public static func send(_ name: BroadcastEvents, value: Any? = nil) {
        NotificationCenter.default.post(name: name.notificationName, object: value)
    }
    public func subscribeTo(_ name: BroadcastEvents, storeIn: inout Set<AnyCancellable>, _ onChange: @escaping (Any?) -> Void) {
       return NotificationCenter.default.publisher(for: name.notificationName)
                .receive(on: DispatchQueue.main)
                .sink { v in
                    if self.ignoreRequest {
                        self.ignoreRequest = false
                        return
                    }
                    self.ignoreRequest = true
                    onChange(v)
                    delayThenMain(0.5, mainBlock: { self.ignoreRequest = false })
                }
                .store(in: &storeIn)
    }
    
    public static func subscribeTo(_ name: BroadcastEvents, _ onChange: @escaping (Any?) -> Void) {
        NotificationCenter.default.addObserver(forName: name.notificationName, object: nil, queue: .main) { v in
            onChange(v)
        }
    }
    
    // MARK: -> Codi Channels
    public static func send(_ name: CodiChannel, value: Any) { name.subject.send(value) }
    public func subscribeTo(_ name: CodiChannel, storeIn: inout Set<AnyCancellable>, _ onChange: @escaping (Any?) -> Void) {
        name.subject
            .receive(on: DispatchQueue.main)
            .sink { v in
                if self.ignoreRequest {
                    self.ignoreRequest = false
                    return
                }
                self.ignoreRequest = true
                onChange(v)
                delayThenMain(0.5, mainBlock: { self.ignoreRequest = false })
            }
            .store(in: &storeIn)
    }
    
    // Consider adding functionality to remove specific subscriptions if needed
    public func unsubscribeAll() { cancellables.removeAll() }
}

public enum BroadcastEvents: String, CaseIterable {
    // MARK: - CORE ENGINE
    case general = "general"
    case central = "central"
    case message = "message"
    case broadcast = "broadcast"
    case window = "window"
    case authChange = "authChange"
    // MARK: - Application Lifecycle
    case appWillTerminate
    case appDidEnterBackground
    case appWillEnterForeground
    case appDidBecomeActive
    case appWillResignActive
    // MARK: - Keyboard Visibility
    case keyboardWillShow
    case keyboardDidShow
    case keyboardWillHide
    case keyboardDidHide
    case keyboardWillChangeFrame
    case keyboardDidChangeFrame
    // MARK: - Orientation and Screen Changes
    case deviceOrientationDidChange
    case deviceBatteryLevelDidChange
    // MARK: - User Defaults
    case defaultsDidChange

    // This computed property converts enum cases to corresponding Notification.Name
    public var notificationName: Notification.Name {
        switch self {
            case .appWillTerminate: return UIApplication.willTerminateNotification
            case .appDidEnterBackground: return UIApplication.didEnterBackgroundNotification
            case .appWillEnterForeground: return UIApplication.willEnterForegroundNotification
            case .appDidBecomeActive: return UIApplication.didBecomeActiveNotification
            case .appWillResignActive: return UIApplication.willResignActiveNotification
            case .keyboardWillShow: return UIResponder.keyboardWillShowNotification
            case .keyboardDidShow: return UIResponder.keyboardDidShowNotification
            case .keyboardWillHide:return UIResponder.keyboardWillHideNotification
            case .keyboardDidHide: return UIResponder.keyboardDidHideNotification
            case .keyboardWillChangeFrame: return UIResponder.keyboardWillChangeFrameNotification
            case .keyboardDidChangeFrame: return UIResponder.keyboardDidChangeFrameNotification
            case .deviceOrientationDidChange: return UIDevice.orientationDidChangeNotification
            case .deviceBatteryLevelDidChange: return UIDevice.batteryLevelDidChangeNotification
            case .defaultsDidChange: return UserDefaults.didChangeNotification
            default: return Notification.Name(self.rawValue)
        }
    }
}



