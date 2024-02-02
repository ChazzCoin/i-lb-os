//
//  SearchBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI

struct SearchBar : View {
    @Binding var text: String
    @State var placeholder: String
    
    var body: some View {
        ZStack {
            SearchBarView(text: $text, placeholder: placeholder)
        }
        .frame(height: 50)
        .background(Color.secondaryBackground)
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

struct SearchBarView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBarView>) -> UISearchBar {
        
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .secondaryBackground
        
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBarView>) {
        uiView.text = text
    }
}

