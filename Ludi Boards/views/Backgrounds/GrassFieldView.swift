//
//  GrassFieldView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import SwiftUI

struct GrassBlade: View {
    var grassColor = Color.green
    
    var body: some View {
        Rectangle()
            .fill(LinearGradient(gradient: Gradient(colors: [grassColor, grassColor.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
            .frame(width: 3, height: 15)
            .rotationEffect(.degrees(10))
    }
}

struct GrassView: View {
    var width = 3000.0
    var height = 4000.0
    var grassCount = 20000
    
    var body: some View {
        ZStack {
            ForEach(0..<grassCount, id: \.self) { _ in
                GrassBlade()
                    .position(x: CGFloat.random(in: 0...CGFloat(width)), y: CGFloat.random(in: 100...CGFloat(height)))
            }
        }.frame(width: width, height: height)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GrassView()
    }
}
