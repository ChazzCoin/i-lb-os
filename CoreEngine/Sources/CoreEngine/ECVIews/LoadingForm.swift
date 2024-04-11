//
//  LoadingForm.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI


public struct LoadingForm<Content:View>: View {
    public var content: (@escaping () -> Void) -> Content
    @Binding public var isLoading: Bool
    @Binding public var showCompletion: Bool
    
    public init(isLoading: Binding<Bool> = .constant(false), showCompletion: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping (@escaping () -> Void) -> Content) {
        self._isLoading = isLoading
        self._showCompletion = showCompletion
        self.content = content
    }
    
    public var body: some View {
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
    
    public func runLoadingProcess() {
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


public struct LoadingCompletionView: View {
    public enum State {
        case loading, completed
    }

    public var state: State
    public var completionText: String = "Completed!"

    public var body: some View {
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
