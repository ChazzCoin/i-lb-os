//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI

public class UserToolsObservable : ObservableObject {
    
    @AppStorage("isConnected") public var isConnected: Bool = false
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("currentUserName") public var currentUserName: String = ""
    @AppStorage("currentUserHandle") public var currentUserHandle: String = ""
    @AppStorage("currentUserRole") public var currentUserRole: String = ""
    @AppStorage("currentUserAuth") public var currentUserAuth: String = ""
    
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    @AppStorage("currentChatId") public var currentChatId: String = ""
    
    @AppStorage("defaultSport") public var defaultSport: String = ""
    
    @AppStorage("currentOrgId") public var currentOrgId: String = ""
    @AppStorage("currentOrgName") public var currentOrgName: String = ""
    
    @AppStorage("currentTeamId") public var currentTeamId: String = ""
    @AppStorage("currentSessionId") public var currentSessionId: String = ""
    @AppStorage("currentActivityId") public var currentActivityId: String = ""
    
    @AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates") public var ignoreUpdates: Bool = false
    
    @AppStorage("fusedQueueIsOn") public var fusedQueueIsOn: Bool = false
    
    public init() {
        self.loadSystemCore()
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
