//
//  SearchBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI


// Master SearchBar
public struct SearchBar : View {
    @Binding public var text: String
    @State public var placeholder: String
    
    public init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        ZStack {
            SearchBarView(text: $text, textColor: Color.black, placeholder: placeholder)
        }
        .frame(height: 30)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}



private struct SearchBarView: UIViewRepresentable {
    @Binding var text: String
    var textColor: Color
    var placeholder: String

    public class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        public init(text: Binding<String>) {
            _text = text
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    public func makeUIView(context: UIViewRepresentableContext<SearchBarView>) -> UISearchBar {
        
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
        
        searchBar.searchTextField.textColor = textColor.uiColor
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: textColor.opacity(0.5).uiColor])
            
        return searchBar
    }

    public func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBarView>) {
        uiView.text = text
    }
}

