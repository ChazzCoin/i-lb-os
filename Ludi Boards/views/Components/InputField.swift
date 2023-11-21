//
//  InputField.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

struct InputField: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.secondary)

            TextField("", text: $value, onEditingChanged: { _ in }, onCommit: {
                // Actions to perform when the user presses the return key
                self.onValueChange(self.value)
                hideKeyboard()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: 44)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 2)
        }
        .padding(.horizontal, 15)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        InputField(label: "Label", value: .constant("Value")) { newValue in
            // Handle value change
        }
    }
}
