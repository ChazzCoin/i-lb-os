//
//  BoardEngineVM.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI


class ViewModel: ObservableObject {
    
    var width: CGFloat = 1500
    var height: CGFloat = 2000
    var startPosX: CGFloat = 1500 / 2
    var startPosY: CGFloat = 2000 / 2
    
    @Published var toolViews: [String] = []
}

struct BoardEngine: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        
        ZStack(){
//            ForEach(viewModel.toolViews, id: \.self) { item in
//                Text(item)
//            }
            DraggableRectangleView()
            
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .position(x: viewModel.startPosX, y: viewModel.startPosY)
        .zIndex(1)
        .background {
            Image("soccer_one")
                .resizable() 
                .aspectRatio(contentMode: .fit) // Fill the area, possibly cropping the image
                .frame(width: viewModel.width, height: viewModel.height) // Match the frame size of the ZStack
                .position(x: viewModel.startPosX, y: viewModel.startPosY)
        }
        .overlay(
            Rectangle() // The rectangle that acts as the border
                .stroke(Color.red, lineWidth: 2) // Red border with a stroke width of 2
                .frame(width: viewModel.width, height: viewModel.height)
                .position(x: viewModel.startPosX, y: viewModel.startPosY)
        ).onAppear {
            print("Sending Hello through General Channel.")
            CodiChannel.general.send(value: "Hello, General Channel!")
        }
    }
}

struct MView: View {
    
    @State private var position = CGPoint(x: 50, y: 50)
    @GestureState private var dragOffset = CGSize.zero
    
    let data: String = ""

    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 300, height: 300)
            // Use the updated position here, adding the drag offset while dragging
            .position(x: position.x, y: position.y)
            .zIndex(15)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($dragOffset, body: { (value, state, transaction) in
                        state = value.translation
                    })
                    .onChanged { value in
                        // Update the position state when the drag ends
                        self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    }
                    .onEnded { value in
                        // Update the position state when the drag ends
                        self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    }
            )
    }
}
