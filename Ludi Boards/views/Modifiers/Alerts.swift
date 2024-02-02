//
//  Alerts.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/1/24.
//

import Foundation
import SwiftUI

extension View {
    
    func alertConfirm(isPresented: Binding<Bool>, title: String, message: String, action: @escaping () -> Void) -> some View {
        self.modifier(ConfirmModifier(showAlert: isPresented, title: title, message: message, action: action))
    }
    
    func alertSave(isPresented: Binding<Bool>, saveAction: @escaping () -> Void) -> some View {
        self.modifier(ConfirmSaveModifier(showAlert: isPresented, saveAction: saveAction))
    }
    
    func alertDelete(isPresented: Binding<Bool>, deleteAction: @escaping () -> Void) -> some View {
        self.modifier(ConfirmDeleteModifier(showAlert: isPresented, deleteAction: deleteAction))
    }
    
}

struct ConfirmModifier: ViewModifier {
    @Binding var showAlert: Bool
    let title: String
    let message: String
    let action: () -> Void
    
    func body(content: Content) -> some View {
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

struct ConfirmSaveModifier: ViewModifier {
    @Binding var showAlert: Bool
    let saveAction: () -> Void
    let title: String = "Save"
    let message: String = "Are you sure you want to save?"
    
    
    func body(content: Content) -> some View {
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

struct ConfirmDeleteModifier: ViewModifier {
    @Binding var showAlert: Bool
    let deleteAction: () -> Void
    let title: String = "Delete"
    let message: String = "Are you sure you want to delete?"
    
    
    func body(content: Content) -> some View {
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


