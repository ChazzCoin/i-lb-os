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
    @State var onChange: (String) -> Void
    var placeholder: String = ""

    init(_ placeholder: String, text: Binding<String>, onChange: @escaping (String) -> Void={ _ in }) {
        self._text = text
        self.placeholder = placeholder
        self.onChange = onChange
    }

    var body: some View {
        ZStack(alignment: .leading) {
            
            TextField("", text: $text)
                .padding(15)
                .background(Color.secondaryBackground)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                                .onTapAnimation {
                                    self.text = ""
                                }.zIndex(10.0)
                        }
                    }
                )
                .transition(.scale)
                .animation(.easeInOut, value: text)
                .onChange(of: text) { newValue in
                    self.text = newValue
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
