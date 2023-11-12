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
            
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .position(x: viewModel.startPosX, y: viewModel.startPosY)
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

struct MyCustomView: View {
    let data: String = ""

    var body: some View {
        // Define your custom view here
        Text(data)
    }
}
