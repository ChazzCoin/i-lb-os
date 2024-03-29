//
//  ModernTextField.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/12/24.
//

import Foundation
import SwiftUI

struct SolSecureField: View {
    @Binding var text: String
    var placeholder: String = ""

    init(_ placeholder: String, text: Binding<String>) {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack(alignment: .leading) {
            
            SecureField("", text: $text)
                .padding(15)
                .background(Color.secondaryBackground)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: { self.text = "" }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 15) 
                            }
                        }
                    }
                )
                .transition(.scale)
                .animation(.easeInOut, value: text)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 15)
                    .transition(.move(edge: .leading))
            }
        }
    }
}
