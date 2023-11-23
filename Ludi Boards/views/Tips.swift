//
//  Tips.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct TipView: View {
    @State private var isVisible = true
    let duration: TimeInterval = 5 // Duration in seconds

    var body: some View {
        if isVisible {
            VStack {
                Text("Your Tip Here")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.blue))
                    .shadow(radius: 10)
            }
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

struct TipView_Previews: PreviewProvider {
    static var previews: some View {
        TipView()
    }
}

