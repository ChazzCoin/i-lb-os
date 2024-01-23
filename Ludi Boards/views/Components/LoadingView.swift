//
//  LoadingView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI

struct LoadingViewModifier: ViewModifier {
    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isShowing)
                .blur(radius: isShowing ? 3 : 0)

            if isShowing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            }
        }
    }
}

extension View {
    func loading(isShowing: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isShowing: isShowing))
    }
}


struct LoadingViewExample: View {
    @State private var isLoading = false

    var body: some View {
        VStack {
            // Your content here
        }
        .loading(isShowing: $isLoading)
        .onAppear {
            executeWithDelay()
        }
    }

    func executeWithDelay() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Your delayed code here
            isLoading = false
            print("Delay complete")
        }
    }
}
