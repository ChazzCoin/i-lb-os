//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI


public class ViewFactory {
    
    public static func HoldView<C: View>(_ view: C) -> () -> C { return { view } }
    public static func HoldView<C: View>(_ view: C) -> C { return view }
    public static func HoldView<C: View>(_ view: C) -> () -> AnyView { return { AnyView(view) } }
    public static func HoldView<C: View>(_ view: C) -> AnyView { return AnyView(view) }

    public static func BuildManagedHolder<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side) -> ManagedViewHolder {
        return ManagedViewHolder(id: callerId, mainBuilder: { mainContent() }, sidebarBuilder: { sideContent() } )
    }
    
}

public class NavViewFactory {
    
    // Constants for types of views
    enum Sport: String {
        case signupProfile = "signup_profile"
        case chat = "chat"
        case nav = "nav"
    }
    
    // Properties representing the type and sport for the view.
    private let subType: Sport
    private let sport: Sport
    
    // Initialize with subType and sport, using Sport enum for better type safety.
    init(subType: Sport, sport: Sport) {
        self.subType = subType
        self.sport = sport
    }
    
    // Returns a view based on the sport. The `nav` sport is assumed to route based on a separate function.
    public func view(viewId: String, activityId: String) -> AnyView {
        switch sport {
            case .nav: return AnyView(EmptyView())
            default: return AnyView(EmptyView())
        }
    }
    
    // Main view generator based on the sport.
    public func mainView() -> AnyView {
        switch sport {
            case .signupProfile: return VF.HoldView(CoreSignUpView())
            case .chat: return VF.HoldView(ChatView())
            default: return VF.HoldView(EmptyView())
        }
    }
    
    // Sidebar view generator based on the sport.
    public func sidebarView() -> AnyView {
        switch sport {
            case .signupProfile: return VF.HoldView(EmptyView())
            case .chat: return VF.HoldView(CoreBuddyListView())
            default: return VF.HoldView(EmptyView())
        }
    }
    
    // Returns a navigation controller loaded with views based on the sport and subType.
    public func navView(viewId: String, activityId: String) -> NavWindowController {
        let managedView = managedViewPair(viewId: viewId, activityId: activityId)
        return NavWindowController().preLoad(window: managedView)
    }
    
    // Constructs a managed view window with main and sidebar views based on the subType.
    public func managedViewPair(viewId: String, activityId: String) -> ManagedViewHolder {
        return ManagedViewHolder(id: viewId, mainBuilder: { self.mainView() }, sidebarBuilder: { self.sidebarView() })
    }
    
    // Example of how to add views with dynamic content. Documentation or usage example.
    public func addDynamicViewExample(callerId: String, mainContent: @escaping () -> AnyView, sideContent: @escaping () -> AnyView) {
        // Example usage within an app's context
    }
    
    // List of all cases. Must be filled with relevant cases if needed.
    public static var allCases: [String] = []
}

