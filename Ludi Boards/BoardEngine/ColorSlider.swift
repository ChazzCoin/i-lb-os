//
//  ColorSlider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

struct BoardColorPicker: View {
    let colors: [Color]
    var callback: (Color) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            callback(color)
                        }
                        .padding(4)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        }
    }
}
