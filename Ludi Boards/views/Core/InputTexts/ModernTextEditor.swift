//
//  ModernTextEditor.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import SwiftUI
import DispatchIntrospection

struct SolTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var title: String
    var color: Color
    @Binding var isEdit: Bool
    @Environment(\.colorScheme) var colorScheme

    init(_ placeholder: String, text: Binding<String>, color: Color = .white) {
        self._text = text
        self.placeholder = placeholder
        self.title = placeholder
        self.color = color
        self._isEdit = .constant(false)
    }
    
    init(_ placeholder: String, text: Binding<String>, color: Color = .white, isEdit: Binding<Bool>) {
        self._text = text
        self.placeholder = placeholder
        self.title = placeholder
        self.color = color
        self._isEdit = isEdit
    }

    var body: some View {
        
        if !isEdit {
            TextLabel(self.title, text: text)
        } else {
            VStack {
                
                AlignLeft {
                    Text(placeholder)
                        .foregroundColor(.blue)
                }
               
                ZStack(alignment: .topLeading) {
                    
                    TextEditor(text: $text)
                        .padding(10)
                        .animation(.easeInOut, value: text)
                        
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.top, 15)
                            .padding(.leading, 20)
                            .transition(.move(edge: .leading))
                    }

                }
                .overlay(
                   RoundedRectangle(cornerRadius: 10)
                    .stroke(getForegroundGradient(colorScheme), lineWidth: 1)
                )
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
            }
            .frame(minHeight: 125)
            .padding(.top)
            
        }
        
        
    }
}

struct CustomTextEditor: View {
    @Binding var text: String
    var placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self._text = text
        self.placeholder = placeholder
    }
    
    @State private var editorHeight: CGFloat = 40 // Default height
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = 150 // Adjust as needed
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray) // Placeholder color
                        .padding(.leading, 12)
                        .padding(.top, 12)
                }
                TextView(text: $text, height: $editorHeight, textColor: getTextColor(colorScheme))
                    .frame(minHeight: editorHeight)
                    .background(Color.clear)
                    .padding(4)
            }
            .background(Color.clear)
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
        .frame(minHeight: minHeight, maxHeight: maxHeight)
        .background(getForegroundGradient(colorScheme))
        .cornerRadius(8)
        
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var textColor: Color
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.backgroundColor = UIColor.clear // Make the UITextView's background transparent
        textView.textColor = UIColor(textColor)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ textView: TextView) {
            self.parent = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.parent.height = textView.contentSize.height
        }
    }
}
