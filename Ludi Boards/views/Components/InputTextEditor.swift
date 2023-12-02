//
//  InputTextEditor.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct InputTextEditor: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ExpandingTextEditor(text: $value, onEditingChanged: { _ in }, onCommit: {
                // Actions to perform when the user presses the return key
                self.onValueChange(self.value)
                hideKeyboard()
            })
        }
        .padding(.horizontal, 15)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct InputTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        InputTextEditor(label: "Label", value: .constant("Value")) { newValue in
            // Handle value change
        }
    }
}
