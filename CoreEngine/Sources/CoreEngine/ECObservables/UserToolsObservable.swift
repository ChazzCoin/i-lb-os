//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI

public class UserToolsObservable : ObservableObject {
    
    @AppStorage("isConnected", store: UserDefaults(suiteName: "worlds")) public var isConnected: Bool = false
    @AppStorage("isLoggedIn", store: UserDefaults(suiteName: "worlds")) public var isLoggedIn: Bool = false
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentUserName", store: UserDefaults(suiteName: "worlds")) public var currentUserName: String = ""
    @AppStorage("currentUserHandle", store: UserDefaults(suiteName: "worlds")) public var currentUserHandle: String = ""
    @AppStorage("currentUserRole", store: UserDefaults(suiteName: "worlds")) public var currentUserRole: String = ""
    @AppStorage("currentUserAuth", store: UserDefaults(suiteName: "worlds")) public var currentUserAuth: String = ""
    
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    @AppStorage("currentChatId", store: UserDefaults(suiteName: "worlds")) public var currentChatId: String = ""
    @AppStorage("currentWidgetId", store: UserDefaults(suiteName: "worlds")) public var currentWidgetId: String = ""
    
    @AppStorage("defaultSport", store: UserDefaults(suiteName: "worlds")) public var defaultSport: String = ""
    
    @AppStorage("currentOrgId", store: UserDefaults(suiteName: "worlds")) public var currentOrgId: String = ""
    @AppStorage("currentOrgName", store: UserDefaults(suiteName: "worlds")) public var currentOrgName: String = ""
    
    @AppStorage("currentTeamId", store: UserDefaults(suiteName: "worlds")) public var currentTeamId: String = ""
    @AppStorage("currentSessionId", store: UserDefaults(suiteName: "worlds")) public var currentSessionId: String = ""
    @AppStorage("currentActivityId", store: UserDefaults(suiteName: "worlds")) public var currentActivityId: String = ""
    
    @AppStorage("isPlayingAnimation", store: UserDefaults(suiteName: "worlds")) public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId", store: UserDefaults(suiteName: "worlds")) public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing", store: UserDefaults(suiteName: "worlds")) public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates", store: UserDefaults(suiteName: "worlds")) public var ignoreUpdates: Bool = false
    
    @AppStorage("fusedQueueIsOn", store: UserDefaults(suiteName: "worlds")) public var fusedQueueIsOn: Bool = false
    
    public init() {
        self.loadSystemCore()
//        if self.currentUserId.isEmpty {
//            self.currentUserId = generateRandomUserId()
//        }
    }
    
    public func loadSystemCore() {
        
        MasterFusedQueue.initializeQueues()
        // Check Internet Connection
        NetworkMonitor.checkInternetConnection { isCon in
            self.isConnected = isCon
        }
        // Check Login Status
        UserTools.verifyLoginStatus()
        MasterFusedQueue.runAllQueues()
    }
    
}
