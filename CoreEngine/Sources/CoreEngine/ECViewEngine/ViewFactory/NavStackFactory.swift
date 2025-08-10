//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI




public class NavViewFactory {
    
    
    // Properties representing the type and sport for the view.
    private let main: SViews.NavStackChild
    private let sidebar: SViews.SideBarCompanion
    
    // Initialize with subType and sport, using Sport enum for better type safety.
    init(main: SViews.NavStackChild, sidebar: SViews.SideBarCompanion) {
        self.main = main
        self.sidebar = sidebar
    }

    @ViewBuilder
    public func mainView() -> some View {
        switch main {
            case .signupProfile: CoreSignUpView()
            case .chat: ChatView()
        }
    }
    
    @ViewBuilder
    public func sidebarView() -> some View {
        switch sidebar {
            case .buddyList: CoreBuddyListView()
        }
    }
    
    // Returns a navigation controller loaded with views based on the sport and subType.
    @MainActor public func navView(viewId: String, activityId: String) -> NavWindowController {
        let managedView = managedViewPair(viewId: viewId, activityId: activityId)
        return NavWindowController().preLoad(window: managedView)
    }
    
    // Constructs a managed view window with main and sidebar views based on the subType.
    public func managedViewPair(viewId: String, activityId: String) -> ManagedViewHolder {
        return ManagedViewHolder(id: viewId, mainBuilder: { self.mainView() }, sidebarBuilder: { self.sidebarView() })
    }
    
    // List of all cases. Must be filled with relevant cases if needed.
    public static var allCases: [String] = []
}

