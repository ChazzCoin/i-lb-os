//
//  StandardButton.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI

struct SolButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    @State private var isButtonPressed = false

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.primaryBackground : Color.gray) // Background color changes when disabled
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
            .animation(.spring(), value: isButtonPressed)
            .padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
            .solEnabled(isEnabled: isEnabled)
            .onTapAnimation {
                if isEnabled {
                    action()
                }
            }
    }
}

struct SolConfirmButton: View {
    let title: String
    let message: String
    let action: () -> Void
    var isEnabled: Bool = true
    @State private var isButtonPressed = false
    @State private var sheetIsShowing = false

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.primaryBackground : Color.gray) // Background color changes when disabled
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
            .animation(.spring(), value: isButtonPressed)
            .solEnabled(isEnabled: isEnabled)
            .onTapAnimation(enabled: isEnabled) {
                if isEnabled {
                    sheetIsShowing = true
                }
            }
            .alert(title, isPresented: $sheetIsShowing) {
                Button("Cancel", role: .cancel) {
                    sheetIsShowing = false
                }
                Button("OK", role: .none) {
                    sheetIsShowing = false
                    action()
                }
            } message: {
                Text(message)
            }
    }
}
