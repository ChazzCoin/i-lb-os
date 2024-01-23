//
//  BorderedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/30/23.
//

import Foundation
import SwiftUI

struct BorderedView<Content: View>: View {
    let content: Content
    var borderColor: Color = .white
    var borderWidth: CGFloat = 2

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    init(color:Color, @ViewBuilder content: () -> Content) {
        self.borderColor = color
        self.content = content()
    }

    var body: some View {
        HStack {
            content
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8) // Adjust corner radius as needed
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
}
