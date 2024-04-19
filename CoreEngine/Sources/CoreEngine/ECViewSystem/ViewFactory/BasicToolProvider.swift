//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

// Child (SubType)
public class BasicToolProvider : ManagedToolProvider {
        
    public var type: String = "basic"
    public var subType: String = ""
    public var sport: String = ""
    init(subType: String, sport: String) {
        self.subType = subType
        self.sport = sport
    }
    
    public static let soccer: String = "soccer"
    public static let pool: String = "pool"
    
    public func view(viewId: String, activityId: String) -> AnyView {
        switch sport {
            case BasicToolProvider.soccer: return SoccerToolProvider(subType: subType).view(viewId: viewId, activityId: activityId)
            case BasicToolProvider.pool: return AnyView(EmptyView())
            default: return AnyView(EmptyView())
        }
    }
    
    public static var allCases: [String] = []
}


/*
 
 public protocol ManagedToolProvider {
     static var allCases: [String] { get }
     var subType: String { get }
     func view(viewId: String, activityId: String) -> AnyView
 }
 
    TOP LEVEL: sport = "canvas" (essentially the top level category of view that routes to this class)
    PARENT VIEW: type = "nav" (now we know its category, we then need to know what Parent View it needs)
    CHILD VIEW: subType = "chat" (the parent view like a NavigationStack is preloaded with Child Views)
 
        RETURNS: A Custom NavWindowController to be used to manage pre-loaded child view(s)
 
 */
// Factory class to create views for a sports app, managing different types of sports views.

/*
    CORE DICTIONARY
 
    -> Tools
    -> Factory
    -> Holder
    -> Broadcast
    -> Controller
    -> Utils
    -> Provider
    -> Extensions
 
 */






