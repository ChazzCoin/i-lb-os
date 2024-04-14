//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI

public typealias VF = ViewFactory

public enum WindowSubscriptions : String, CaseIterable {
    case master = "master"
    case home = "home"
    case chat = "chat"
    case profile = "profile"
    case dashboard = "dashboard"
    case settings = "settings"
}

public class ViewFactory {
    
    public static func Build<Content: View, Sidebar: View>(
        callerId: String, isFloatable: Bool = false,
        @ViewBuilder viewContent: @escaping () -> Content,
        @ViewBuilder sideContent: @escaping () -> Sidebar = { EmptyView() }
    ) -> ManagedViewWindow {
        // Nav Window Holder
        let nsw = NavStackWindow(
            id: callerId, isFloatable: isFloatable,
            contentBuilder: { viewContent() },
            sideBarBuilder: { sideContent() }
        )
        // View Holder
        return ManagedViewWindow(id: callerId, viewBuilder: { nsw })
    }
    
    @ViewBuilder
    public static func BuildNavStackWindow<Content: View, Sidebar: View>(
        callerId: String, isFloatable: Bool = false,
        @ViewBuilder viewContent: @escaping () -> Content,
        @ViewBuilder sideContent: @escaping () -> Sidebar = { EmptyView() }
    ) -> some View {
        // Nav Window Holder
        NavStackWindow(
            id: callerId, isFloatable: isFloatable,
            contentBuilder: { viewContent() },
            sideBarBuilder: { sideContent() }
        )
        
    }

    public static func BuildManagedViewWindow<Content: View>(callerId: String, @ViewBuilder viewContent: @escaping () -> Content) -> ManagedViewWindow {
        // View Holder
        return ManagedViewWindow(id: callerId, viewBuilder: { viewContent() } )
    }
}
