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
                
            }
//            .padding()
        }
        .frame(height: 75)
        .onAppear() {
            self.selectedImage = self.initialSelected
        }
        
    }
    
}


// SwiftUI View for the Emoji Picker
struct BoardListPicker: View {
    var id: String
    var initialSelected: String
    var viewBuilder: [String: () -> AnyView]
    var callback: (String) -> Void
    @State var selectedImage: String = ""
    @State var screenHeight = UIScreen.main.bounds.height
    @State var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    
    init(_ id: String="", initialSelected: String="", viewBuilder:  [String:() -> AnyView], callback: @escaping (String) -> Void) {
        self.id = id
        self.initialSelected = initialSelected
        self.viewBuilder = viewBuilder
        self.callback = callback
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(viewBuilder.keys.sorted(), id: \.self) { key in
                    HStack {
                        viewBuilder[key]?()
                            .padding(5)
                            .cornerRadius(10.0)
                            .onTapAnimation {
                                self.selectedImage = key
                                callback(key)
                            }
                        BodyText(key)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(height: screenHeight * 0.75, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        .onAppear() {
            self.selectedImage = self.initialSelected
        }
        
    }
    
}
