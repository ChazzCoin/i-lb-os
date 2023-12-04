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
    var viewBuilder: [() -> AnyView]
    @Environment(\.colorScheme) var colorScheme
    
    init(_ id: String="", viewBuilder:  [() -> AnyView]) {
        self.id = id
        self.viewBuilder = viewBuilder
    }
    
    // State to track the selected image
    @State private var selectedImage: Int = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewBuilder.count, id: \.self) { index in
                    self.viewBuilder[index]()
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedImage == index ? Color.blue : Color.clear, lineWidth: 3)
                        )
                        .onTapAnimation {
                            self.selectedImage = index
                        }
                }
                
            }.padding()
        }
        .frame(height: 100)
        
    }
    
}
