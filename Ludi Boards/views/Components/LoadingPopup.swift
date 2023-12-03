//
//  LoadingPopup.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI

struct LoadingCompletionView: View {
    enum State {
        case loading, completed
    }

    var state: State
    var completionText: String = "Completed!"

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                if state == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                    Text(completionText)
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .padding(40)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}
