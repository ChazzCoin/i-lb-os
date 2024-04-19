//
//  Tips.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import CoreEngine

struct TipView: View {
    @State var tip: String
    @State private var isVisible = true
    let duration: TimeInterval = 5 // Duration in seconds
    @State var gps = GlobalPositioningSystem(CoreNameSpace.local)
    var body: some View {
        if isVisible {
            VStack {
                Text(tip)
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.blue))
                    .shadow(radius: 10)
            }
//            .position(x: gps.getCoordinate(for: .topRight).x - 250, y: gps.getCoordinate(for: .topRight).y + 200)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}

struct TipViewLocked: View {
    @State var tip: String
    @Binding var isVisible: Bool
    
    let duration: TimeInterval = 5 // Duration in seconds
    @State var gps = GlobalPositioningSystem(CoreNameSpace.local)
    var body: some View {
        if isVisible {
            VStack {
                Text(tip)
                    .font(.headline)
                    .padding()
                    .foregroundColor(.black)
                    .shadow(radius: 10)
//                Spacer()
//                FlashingLightView(isEnabled: $isVisible)
            }
            .background(Capsule().fill(Color.blue).opacity(0.2))
            .opacity(isVisible ? 1 : 0)
            .position(x: gps.getCoordinate(for: .topRight).x - 200, y: gps.getCoordinate(for: .topRight).y + 50)
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//                    withAnimation {
//                        isVisible = false
//                    }
//                }
//            }
        }
    }
}


struct TipView_Previews: PreviewProvider {
    static var previews: some View {
        TipView(tip: "Yo Ho Ho")
    }
}

