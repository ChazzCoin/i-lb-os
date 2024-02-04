//
//  ThumbnailListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct ThumbnailListView: View {
    // Assuming you have an array of image names from your assets
    var callback: (String) -> Void
    let imageNames: [String] = ["soccer_two", "soccer_one", "basketball_one", "basketball_two"]

    // State to track the selected image
    @State private var selectedImage: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedImage == imageName ? Color.blue : Color.clear, lineWidth: 3)
                        )
                        .onTapAnimation {
                            self.selectedImage = imageName
                            callback(imageName)
                        }
                }
            }
            .padding()
        }
    }
}

struct ColorListPicker: View {
    var callback: (Color) -> Void
    @State var colorNamesProvider = Array(colorDict().values)

    @State private var selectedImage: Color = Color.black

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(colorNamesProvider, id: \.self) { colorName in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorName)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedImage == colorName ? Color.blue : Color.clear, lineWidth: 3)
                        )
                        .highPriorityGesture(TapGesture()
                            .onEnded { _ in
                                self.selectedImage = colorName
                                callback(colorName)
                            }
                        )
                }
            }
        }
    }
}

struct ColorListPickerView: View {
    var id: String
    var callback: (Color) -> Void
    
    @State var colorNamesProvider = Array(colorDict().values)
    @State var selectedColor: Color = .white
    @State var screenHeight = UIScreen.main.bounds.height
    @State var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    
    init(_ id: String = "", initialSelected: Color = .white, callback: @escaping (Color) -> Void) {
        self.id = id
        self.callback = callback
        self.selectedColor = initialSelected
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(colorNamesProvider, id: \.self) { colorName in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorName)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedColor == colorName ? Color.blue : Color.clear, lineWidth: 3)
                        )
                        .highPriorityGesture(TapGesture()
                            .onEnded { _ in
                                self.selectedColor = colorName
                                callback(colorName)
                            }
                        )
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
    }
    
}
