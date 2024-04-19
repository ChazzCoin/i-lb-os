//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI


public extension CoreName {
    
    class Size {
        
        public enum NavStack: String, CaseIterable {
            case full = "fullscreen"
            case full_menu_bar = "fullscreen_menu_bar"
            case half = "half"
            case floatable_large = "floatable_large"
            case floatable_medium = "floatable_medium"
            case floatable_small = "floatable_small"
            public var name: String { rawValue }
            
            public var height: Double {
                switch self {
                    case .full: return UIScreen.main.bounds.height
                    case .full_menu_bar: return UIScreen.main.bounds.height
                    case .half: return UIScreen.main.bounds.height * 0.5
                    case .floatable_large: return UIScreen.main.bounds.height * 0.6
                    case .floatable_medium: return UIScreen.main.bounds.height * 0.5
                    case .floatable_small: return UIScreen.main.bounds.height * 0.4
                }
            }
            
            public var width: Double {
                switch self {
                    case .full: return UIScreen.main.bounds.width
                    case .full_menu_bar: return UIScreen.main.bounds.width * 0.9
                    case .half: return UIScreen.main.bounds.width * 0.5
                    case .floatable_large: return UIScreen.main.bounds.width * 0.6
                    case .floatable_medium: return UIScreen.main.bounds.width * 0.5
                    case .floatable_small: return UIScreen.main.bounds.width * 0.4
                }
            }
        }
    }
    
}
