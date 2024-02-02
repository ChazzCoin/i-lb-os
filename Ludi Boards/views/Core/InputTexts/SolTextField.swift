//
//  ModernTextField.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/12/24.
//

import Foundation
import SwiftUI

struct SolTextField: View {
    @Binding var text: String
    var onChange: (String) -> Void
    var placeholder: String = ""
    @Binding var isEditable: Bool // Add this line to bind an external state for edit/view mode.

    init(_ placeholder: String, text: Binding<String>, isEditable: Binding<Bool>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = isEditable // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }
    
    init(_ placeholder: String, text: Binding<String>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = .constant(true) // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }

    var body: some View {
        ZStack(alignment: .leading) {
            
            TextField("", text: $text)
                .disabled(!isEditable) // Use the isEditable state to enable or disable the text field.
                .padding(15)
                .background(isEditable ? Color.secondaryBackground : Color.secondaryBackground.opacity(0.9)) // Change background based on isEditable.
                .foregroundColor(isEditable ? .white : .white) // Change text color based on isEditable.
                .cornerRadius(10)
                .shadow(color: .gray.opacity(isEditable ? 0.4 : 0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty && isEditable {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    self.text = ""
                                }.zIndex(10.0)
                        }
                    }
                )
                .transition(.scale)
                .animation(.easeInOut, value: text)
                .onChange(of: text) { newValue in
                    onChange(newValue) // Call onChange when text changes
                }
                
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 15)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

struct SolNumberField: View {
    @Binding var number: Double
    var placeholder: String
    var formatter: NumberFormatter
    var onChange: (Double) -> Void

    init(_ placeholder: String, number: Binding<Double>, formatter: NumberFormatter = NumberFormatter(), onChange: @escaping (Double) -> Void = { _ in }) {
        self._number = number
        self.placeholder = placeholder
        self.formatter = formatter
        self.onChange = onChange

        // Configure the number formatter as needed (e.g., for decimal numbers, currency, etc.)
        self.formatter.numberStyle = .decimal
        self.formatter.minimumFractionDigits = 0 // Adjust as needed
        self.formatter.maximumFractionDigits = 2 // Adjust as needed
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", value: $number, formatter: formatter)
                .padding(15)
                .background(Color.secondaryBackground)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                .keyboardType(.decimalPad)
                .overlay(
                    HStack {
                        Spacer()
                        if number != 0 {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    self.number = 0
                                }
                                .zIndex(10.0)
                        }
                    }
                )
                .transition(.scale)
                .animation(.easeInOut, value: number)
                .onChange(of: number) { newValue in
                    self.onChange(newValue)
                }

            if number == 0 {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 15)
                    .transition(.move(edge: .leading))
            }
        }
    }
}
