//
//  DSideBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/30/24.
//

import Foundation
import SwiftUI

// Define your generic sidebar content
struct DSidebarWindow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Form {
            content
        }
        .frame(width: 300, height: UIScreen.main.bounds.height, alignment: .leading)
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}
