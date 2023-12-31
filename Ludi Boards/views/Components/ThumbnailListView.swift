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
                    Button(action: {
                        self.selectedImage = imageName
                        callback(imageName)
                    }) {
                        Image(imageName)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedImage == imageName ? Color.blue : Color.clear, lineWidth: 3)
                            )
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
            HStack(spacing: 10) {
                ForEach(colorNamesProvider, id: \.self) { colorName in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorName)
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
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
            .padding()
        }
    }
}

//struct ThumbnailListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ThumbnailListView() { item in
//            print(item)
//        }
//    }
//}
