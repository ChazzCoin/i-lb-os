//
//  Alerts.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/1/24.
//

import Foundation
import SwiftUI

public extension View {
    
    func alertConfirm(isPresented: Binding<Bool>, title: String, message: String, action: @escaping () -> Void) -> some View {
        self.modifier(ConfirmModifier(showAlert: isPresented, title: title, message: message, action: action))
    }
    
    func alertSave(isPresented: Binding<Bool>, saveAction: @escaping () -> Void) -> some View {
        self.modifier(ConfirmSaveModifier(showAlert: isPresented, saveAction: saveAction))
    }
    
    func alertDelete(isPresented: Binding<Bool>, deleteAction: @escaping () -> Void) -> some View {
        self.modifier(ConfirmDeleteModifier(showAlert: isPresented, deleteAction: deleteAction))
    }
    
    func isLoading(showLoading: Binding<Bool>, loadingText: String = "Loading...") -> some View {
        self.modifier(LoadingViewModifier(showLoading: showLoading, loadingText: loadingText))
    }
    
}

public struct ConfirmModifier: ViewModifier {
    @Binding var showAlert: Bool
    let title: String
    let message: String
    let action: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $showAlert) {
                Button("Cancel", role: .cancel) {
                    showAlert = false
                }
                Button("OK", role: .none) {
                    showAlert = false
                    action()
                }
            } message: {
                Text(message)
            }
    }
}

public struct ConfirmSaveModifier: ViewModifier {
    @Binding var showAlert: Bool
    let saveAction: () -> Void
    let title: String = "Save"
    let message: String = "Are you sure you want to save?"
    
    
    public func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $showAlert) {
                Button("Cancel", role: .cancel) {
                    showAlert = false
                }
                Button("OK", role: .none) {
                    showAlert = false
                    saveAction()
                }
            } message: {
                Text(message)
            }
    }
}

public struct ConfirmDeleteModifier: ViewModifier {
    @Binding public var showAlert: Bool
    public let deleteAction: () -> Void
    public let title: String = "Delete"
    public let message: String = "Are you sure you want to delete?"
    
    
    public func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $showAlert) {
                Button("Cancel", role: .cancel) {
                    showAlert = false
                }
                Button("OK", role: .none) {
                    showAlert = false
                    deleteAction()
                }
            } message: {
                Text(message)
            }
    }
}


public struct LoadingViewModifier: ViewModifier {
    @Binding public var showLoading: Bool
    public var loadingText: String = "Loading..."

    public func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: showLoading ? 3 : 0)
                .disabled(showLoading)

            if showLoading {
                // Loading Overlay
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                // Loading Indicator and Text
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)

                    Text(loadingText)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(40)
                .background(Color(.systemBackground).opacity(0.85))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }
}
