//
//  DSideBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/30/24.
//

import Foundation
import SwiftUI
import CoreEngine

// Define your generic sidebar content
struct DSidebarWindow<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
                .padding()
        }
        .frame(width: 300, height: UIScreen.main.bounds.height, alignment: .leading)
        .background(getBackgroundGradient(colorScheme))
    }
}
