//
//  PopupMenu.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

//struct PopupMenu: View {
//    let viewId: String
//    var callback: (() -> Void)?
//
//    // State variables for position offset
//    @State private var offsetX: CGFloat = 0
//    @State private var offsetY: CGFloat = 0
//    
//    private let screenHeight = UIScreen.main.bounds.height
//    private let screenWidth = UIScreen.main.bounds.width/2
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Image(systemName: "trash.fill") // Replace with your image
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .onTapGesture {
//                        // Handle delete action
//                        callback?()
//                    }
//            }
//            .padding(.all, 8)
//            
//            // Color Picker Placeholder
//            BoardColorPicker(){ item in }
//            Spacer().frame(height: 4)
//
//            RotationSlider(viewId: "")
//            Spacer().frame(height: 4)
//
//            WidthHeightSlider(viewId: "")
//            Spacer().frame(height: 4)
//
//        }
//        .padding(4)
//    }
//
//}

//struct SlideOutMenu: View {
//    @State private var isVisible: Bool = true
//    @State private var offsetY: CGFloat = 400 // initial offset
//    @State private var viewId: String = ""
//    private let screenHeight = UIScreen.main.bounds.height
//    private let screenWidth = UIScreen.main.bounds.width
//
//    var body: some View {
//        if isVisible {
//            VStack {
//                PopupMenu(viewId: "")
//            }
//            .frame(width: 300, height: screenHeight)
//            .background(Color.black)
//            .offset(x: screenWidth - 300, y: offsetY)
//            .animation(.easeInOut)
//            .gesture(
//                DragGesture()
//                    .onChanged { gesture in
//                        self.offsetY = gesture.translation.height
//                    }
//                    .onEnded { _ in
//                        if self.offsetY > 100 { // Threshold to hide
//                            self.hideMenu()
//                        } else {
//                            self.offsetY = 0 // Reset position
//                        }
//                    }
//            )
//            .onAppear {
//                self.showMenu()
//            }
//        }
//        
//    }
//
//    private func showMenu() {
//        self.isVisible = true
//        self.offsetY = 0
//    }
//
//    private func hideMenu() {
//        self.isVisible = false
//        self.offsetY = 400 // Or any other value that hides the menu
//    }
//
//}

// Replace with your actual PopupMenu
// struct PopupMenu: View { ... }
