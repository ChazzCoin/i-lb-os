//
//  CoreMods.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

extension View {
    func dragger() -> some View {
        self.modifier(lbDragger())
    }
    
    func enableMVT(viewId: String="") -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, boardId: "boardEngine-1"))
    }
}

// Helper view to simulate Box from Compose
struct BoxView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        // Add your custom modifiers here
    }
}
