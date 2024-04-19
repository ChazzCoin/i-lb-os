//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI

public extension CoreName {
    
    class Views {
        
        
        public enum NavStack: String, CaseIterable {
            case signupProfile = "signupProfile"
            case chat = "chat"
            public var name: String {rawValue}
        }
        
        public enum MenuBarCompanion: String, CaseIterable {
            case buddyList = "buddyList"
            public var name: String {rawValue}
        }
        
        public enum Panel: String, CaseIterable {
            case notification = "notification"
            case mode = "mode"
            case tipBox = "tipBox"
            public var name: String {rawValue}
        }
        
    }
    
}

public protocol ObservablePanel: ObservableObject {
    init(title: String, subtitle: String)
}
public class PanelViewFactory {
    
    public static func view(coreName: CoreName.Views.Panel, title: String, subtitle: String) -> (any ObservablePanel)? {
        switch coreName {
//        case .notification: return VF.HoldView(NotificationPanel(message: .constant(""), icon: .constant("")))
            case .mode: return PanelModeController(title: title, subTitle: subtitle)
//        case .tipBox: return VF.HoldView()
            default: return nil
        }
    }
    
}

