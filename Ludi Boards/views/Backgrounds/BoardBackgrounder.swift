//
//  BoardBackgrounder.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import SwiftUI

struct FieldOverlayView<Background: View, Overlay: View>: View {
    let width: Double
    let height: Double
    let background: Background
    let overlay: Overlay

    init(width: Double, height: Double, @ViewBuilder background: () -> Background, @ViewBuilder overlay: () -> Overlay) {
        self.width = width
        self.height = height
        self.background = background()
        self.overlay = overlay()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background
                    .frame(width: width, height: height)
                overlay
                    .frame(width: width, height: height)
            }
        }
    }
}

