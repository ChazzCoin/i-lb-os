//
//  FlashingLight.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/29/23.
//

import Foundation
import SwiftUI

struct FlashingLightView: View {
    @Binding var isEnabled: Bool
    @State private var isFlashing = false
    
    @State var gps = GlobalPositioningSystem()

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 25, height: 25)
            .opacity(isFlashing && isEnabled ? 1.0 : 0.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isFlashing.toggle()
                }
            }
            .position(x: gps.getCoordinate(for: .topRight).x - 50, y: gps.getCoordinate(for: .topRight).y + 50)
    }
}

//struct FlashingLightView_Previews: PreviewProvider {
//    @State var e: Bool = false
//    static var previews: some View {
//        FlashingLightView(isEnabled: $e)
//    }
//}
