//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public extension CoreName {
    
    class Channels {
        
        public enum System: String, CaseIterable {
            case broadcast = "broadcast"
            case window = "window"
            case authChange = "authChange"
            case appWillTerminate = "appWillTerminate"
            case appDidEnterBackground = "appDidEnterBackground"
            case appWillEnterForeground = "appWillEnterForeground"
            case appDidBecomeActive = "appDidBecomeActive"
            case appWillResignActive = "appWillResignActive"
            case keyboardWillShow = "keyboardWillShow"
            case keyboardDidShow = "keyboardDidShow"
            case keyboardWillHide = "keyboardWillHide"
            case keyboardDidHide = "keyboardDidHide"
            case keyboardWillChangeFrame = "keyboardWillChangeFrame"
            case keyboardDidChangeFrame = "keyboardDidChangeFrame"
            case deviceOrientationDidChange = "deviceOrientationDidChange"
            case deviceBatteryLevelDidChange = "deviceBatteryLevelDidChange"
            case defaultsDidChange = "defaultsDidChange"
            public var name: String { rawValue }
        }

        public enum Codi: String, CaseIterable {
            case general = "general"
            case central = "central"
            case message = "message"
            case broadcast = "broadcast"
            case navStackMessage = "navStackMessage"
            case sessionOnIdChange = "sessionOnIdChange"
            case activityOnIdChange = "activityOnIdChange"
            case menuToggler = "menuToggler"
            case menuSettingsToggler = "menuSettingsToggler"
            case toolSettingsToggler = "toolSettingsToggler"
            case menuWindowToggler = "menuWindowToggler"
            case menuWindowController = "menuWindowController"
            case toolOnCreate = "toolOnCreate"
            case toolOnDelete = "toolOnDelete"
            case toolSubscription = "toolSubscription"
            case toolOnMenuReturn = "toolOnMenuReturn"
            case toolOnFollow = "toolOnFollow"
            case toolAttributes = "toolAttributes"
            case realmOnChange = "realmOnChange"
            case realmOnDelete = "realmOnDelete"
            case emojiOnCreate = "emojiOnCreate"
            case onLogInOut = "onLogInOut"
            case onNotification = "onNotification"
            public var name: String { rawValue }
        }
        
        
    }
}
