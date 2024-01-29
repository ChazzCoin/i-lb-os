//
//  ModernTextEditor.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import SwiftUI

struct SolTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var title: String

    init(_ placeholder: String, text: Binding<String>) {
        self._text = text
        self.placeholder = placeholder
        self.title = placeholder
    }

    var body: some View {
        
        VStack {
            
            AlignLeft {
                BodyText(title)
            }
            
            ZStack(alignment: .topLeading) {
                
                TextEditor(text: $text)
                    .padding(10)
                    .background(Color.secondaryBackground)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .animation(.easeInOut, value: text)
                
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(.top, 15)
                        .padding(.leading, 20)
                        .transition(.move(edge: .leading))
                }

            }
        }
        
    }
}

struct ModernTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        SolTextEditor("Enter text here...", text: .constant(""))
    }
}
