//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI


public extension CoreName {
    
    class State {
        
        public enum OpenClosed: String, CaseIterable {
            case open = "open"
            case closed = "closed"
            public var name: String { rawValue }

            @available(iOS 16.0, *)
            public var sidebar: NavigationSplitViewVisibility {
                switch self {
                    case .open: return .doubleColumn
                    case .closed: return .detailOnly
                }
            }
            public var main: Bool {
                switch self {
                    case .open: return true
                    case .closed: return false
                }
            }
            
        }
        
    }
    
    
}
