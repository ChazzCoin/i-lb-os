//
//  ModernTextField.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/12/24.
//

import Foundation
import SwiftUI

public struct CoreInputText : View {
    @State public var label: String = ""
    @Binding public var text: String
    @Binding public var isEdit: Bool
    
    public init(label: String, text: Binding<String>, isEdit: Binding<Bool>) {
        self.label = label
        self._text = text
        self._isEdit = isEdit
    }
    
    public var body: some View {
        if !isEdit {
            TextLabel(label, text: text)
        } else {
            CoreTextField(label, text: $text)
        }
    }
}


public struct CoreTextField: View {
    @Binding var text: String
    var onChange: (String) -> Void
    var placeholder: String = ""
    @Binding var isEditable: Bool // Add this line to bind an external state for edit/view mode.
    @Environment(\.colorScheme) var colorScheme

    public init(_ placeholder: String, text: Binding<String>, isEditable: Binding<Bool>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = isEditable // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }
    
    public init(_ placeholder: String, text: Binding<String>, onChange: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self._isEditable = .constant(true) // Initialize it here.
        self.placeholder = placeholder
        self.onChange = onChange
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            
            TextField("", text: $text)
                .font(.headline)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
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

public struct SolNumberField: View {
    @Binding var number: Double
    var placeholder: String
    var formatter: NumberFormatter
    var onChange: (Double) -> Void

    public init(_ placeholder: String, number: Binding<Double>, formatter: NumberFormatter = NumberFormatter(), onChange: @escaping (Double) -> Void = { _ in }) {
        self._number = number
        self.placeholder = placeholder
        self.formatter = formatter
        self.onChange = onChange

        // Configure the number formatter as needed (e.g., for decimal numbers, currency, etc.)
        self.formatter.numberStyle = .decimal
        self.formatter.minimumFractionDigits = 0 // Adjust as needed
        self.formatter.maximumFractionDigits = 2 // Adjust as needed
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            TextField("", value: $number, formatter: formatter)
                .padding(15)
//                .background(Color.secondaryBackground)
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
