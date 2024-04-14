//
//  ExpandingTextEditor.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI


// idk yet
public struct ExpandingTextEditor: View {
    var text: Binding<String>
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    @State private var editorHeight: CGFloat = 100

    public var body: some View {
        TextEditor(text: text)
            .frame(minHeight: editorHeight, maxHeight: editorHeight)
            .onChange(of: text.wrappedValue) { newText in
                self.editorHeight = newText.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: UIFont.systemFont(ofSize: 18))
                onEditingChanged(true)
            }
            .onSubmit {
                onCommit()
            }
            .onAppear {
                self.editorHeight = text.wrappedValue.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: UIFont.systemFont(ofSize: 18))
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}


