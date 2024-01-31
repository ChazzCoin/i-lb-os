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
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                content
            }
        }
        .padding()
        .frame(width: 300, height: UIScreen.main.bounds.height, alignment: .leading)
        .background(Color.gray.opacity(0.95))
        .edgesIgnoringSafeArea(.all)
    }
}
