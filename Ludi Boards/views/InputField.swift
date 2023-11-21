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
            Spacer().frame(width: 25)
            Text(label)
            Spacer().frame(width: 25)
            TextField("", text: $value, onEditingChanged: { _ in }, onCommit: {
                // Actions to perform when the user presses the return key
                self.onValueChange(self.value)
                hideKeyboard()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(8)
        }
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
