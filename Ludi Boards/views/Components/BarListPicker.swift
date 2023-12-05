//
//  BarListPicker.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/3/23.
//

import Foundation
import SwiftUI

// SwiftUI View for the Emoji Picker
struct BarListPicker: View {
    var id: String
    var initialSelected: String
    var viewBuilder: [String: () -> AnyView]
    var callback: (String) -> Void
    @State var selectedImage: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    
    init(_ id: String="", initialSelected: String="", viewBuilder:  [String:() -> AnyView], callback: @escaping (String) -> Void) {
        self.id = id
        self.initialSelected = initialSelected
        self.viewBuilder = viewBuilder
        self.callback = callback
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewBuilder.keys.sorted(), id: \.self) { key in
                    viewBuilder[key]?()
                        .padding(5)
                        .background(Color.gray)
                        .cornerRadius(10.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedImage == key ? backgroundColorForScheme(colorScheme) : Color.clear, lineWidth: 3)
                        )
                        .onTapAnimation {
                            self.selectedImage = key
                            callback(key)
                        }
                }
                
            }.padding()
        }
        .frame(height: 100)
        .onAppear() {
            self.selectedImage = self.initialSelected
        }
        
    }
    
}
