//
//  StopWatch.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/4/23.
//

import Foundation
import SwiftUI

struct StopwatchView: View {
//    @StateObject var viewModel = StopwatchViewModel()
    
    var body: some View {
        VStack {
            Text("0:00:00")
                .font(.system(size: 40, weight: .bold, design: .default))
                .padding()

            HStack {
                Button(action: {
                    // Start or Stop Logic
                }) {
                    Text("Start/Stop")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                Button(action: {
                    // Reset Logic
                }) {
                    Text("Reset")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
