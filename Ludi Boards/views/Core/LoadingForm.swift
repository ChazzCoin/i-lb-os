//
//  LoadingForm.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI
import CoreEngine

// ActivityPlan View
struct LoadingForm<Content:View>: View {
    var content: (@escaping () -> Void) -> Content
    @Binding var isLoading: Bool
    @Binding var showCompletion: Bool
    
    init(isLoading: Binding<Bool> = .constant(false), showCompletion: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping (@escaping () -> Void) -> Content) {
        self._isLoading = isLoading
        self._showCompletion = showCompletion
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Form {
                content(runLoadingProcess)
            }
            .blur(radius: isLoading || showCompletion ? 3 : 0) // Optional: blur form when loading

            if isLoading || showCompletion {
                LoadingCompletionView(state: showCompletion ? .completed : .loading)
            }
        }
    }
    
    func runLoadingProcess() {
        isLoading = true
        // Simulate a network request or some processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCompletion = false
            }
        }
    }
    
}


