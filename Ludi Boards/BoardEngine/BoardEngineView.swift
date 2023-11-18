//
//  BoardEngineView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct BoardEngine: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        
        ZStack(){
            ForEach(Array(viewModel.toolViews.values)) { item in
                item.view()
            }
//            ManagedViewBoardTool(boardId: "", viewId: "", toolType: "")
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .position(x: viewModel.startPosX, y: viewModel.startPosY)
        .background {
            Image("soccer_one")
                .resizable()
                .aspectRatio(contentMode: .fill) // Fill the area, possibly cropping the image
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

