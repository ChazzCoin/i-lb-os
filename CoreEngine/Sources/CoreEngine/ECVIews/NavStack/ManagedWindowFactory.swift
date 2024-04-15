//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI



//public enum WindowSubscriptions : String, CaseIterable {
//    case master = "master"
//    case home = "home"
//    case chat = "chat"
//    case profile = "profile"
//    case dashboard = "dashboard"
//    case settings = "settings"
//}

public class ViewFactory {
    
    public static func BuildView<Content: View>(_ view: Content) -> () -> AnyView { return { AnyView(view) } }
    
//    public static func BuildManagedStack<Content: View, Sidebar: View>(
//        callerId: String, isFloatable: Bool = false,
//        @ViewBuilder viewContent: @escaping () -> Content,
//        @ViewBuilder sideContent: @escaping () -> Sidebar = { EmptyView() }
//    ) -> ManagedViewWindow {
//        // Nav Window Holder
//        let nsw = NavStackWindow(
//            id: callerId, isFloatable: isFloatable,
//            contentBuilder: { viewContent() },
//            sideBarBuilder: { sideContent() }
//        )
//        // View Holder
//        return ManagedViewWindow(id: callerId, viewBuilder: { nsw })
//    }
    
//    @ViewBuilder
//    public static func BuildStackWindow<Content: View, Sidebar: View>(
//        callerId: String, isFloatable: Bool = false,
//        @ViewBuilder viewContent: @escaping () -> Content = { EmptyView() },
//        @ViewBuilder sideContent: @escaping () -> Sidebar = { EmptyView() }
//    ) -> some View {
//        // Nav Window Holder
//        NavStackWindow(
//            id: callerId, isFloatable: isFloatable,
//            contentBuilder: { viewContent() },
//            sideBarBuilder: { sideContent() }
//        )
//    }
    
    
//    public static func BuildEmptyStackWindow<Content: View, SideBar: View>(callerId: String, isFloatable: Bool = false) -> NavStackManager<Content,SideBar> {
//        // Nav Window Holder
//        return NavStackManager<Content,SideBar>()
//    }

    public static func BuildManagedHolder<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side) -> ManagedViewWindow {
        // View Holder
        return ManagedViewWindow(id: callerId, mainBuilder: { mainContent() }, sidebarBuilder: { sideContent() } )
    }
}
