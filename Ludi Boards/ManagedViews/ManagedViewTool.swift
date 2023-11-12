//
//  ManagedViewTool.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI

struct ManagedViewBoardTool: View {
    let boardId: String
    let viewId: String
    let toolType: String

    // State variables in SwiftUI to replace remember
    @State private var popUpIsVisible = false
    @State private var color: Color = .black
    @State private var rotation: CGFloat = 0

    // Assuming toolParser is a function available in your Swift code
    private var tool: String // Replace `Tool` with the actual type returned by toolParser

    init(boardId: String, viewId: String, toolType: String) {
        self.boardId = boardId
        self.viewId = viewId
        self.toolType = toolType
        self.tool = "toolParser(toolType)"
    }

    var body: some View {
        // Replace CodiTheme with your SwiftUI theme or remove it if not needed
        BoxView {  // Replace with the SwiftUI equivalent of Box
            // Image component
            Image(uiImage: UIImage(named: "tool.res") ?? UIImage()) // Assuming tool.res is the image name
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(Double(rotation)))
                .colorMultiply(getColor() ? Color.red : color) // Adjust this line based on your color logic
                .border(popUpIsVisible ? Color.red : Color.clear, width: 1) // Border modifier
                // Tap gestures
                .onTapGesture {
                    popUpIsVisible.toggle()
                }
//                .onDoubleTap {
//                    popUpIsVisible = false
//                }
                // Additional custom modifiers would go here
        }
        .onAppear {
            print("TOOL: MVBT: \("tool.title"), \(boardId), \(viewId)")
        }
    }

    private func getColor() -> Bool {
        toolType.allSatisfy { $0.isNumber }
    }
}

// Helper view to simulate Box from Compose
struct BoxView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        // Add your custom modifiers here
    }
}
