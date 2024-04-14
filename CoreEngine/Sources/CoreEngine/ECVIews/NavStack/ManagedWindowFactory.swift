//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI


public class ManagedWindowFactory {
    
    public static func Build<Content: View, Sidebar: View>(
        
        callerId: String,
        @ViewBuilder viewContent: @escaping () -> Content,
        @ViewBuilder sideContent: @escaping () -> Sidebar
    
    ) -> ManagedViewWindow {
        
        // Nav Window Holder
        let nsw = NavStackWindow(
            id: callerId,
            isFloatable: false,
            contentBuilder: {
                viewContent()
            },
            sideBarBuilder: {
                sideContent()
            }
        )
        // View Holder
        return ManagedViewWindow(
            id: callerId,
            viewBuilder: {
                nsw
            }
        )
        
    }
    
//    func addChatWindow() {
//        let caller = MenuBarProvider.chat.tool.title
//        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
//            
//        })
//    }
}
