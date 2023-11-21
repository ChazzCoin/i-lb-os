//
//  BoardEngineView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine

struct BoardEngine: View {
    
    @State var cancellables = Set<AnyCancellable>()
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack(){
            ForEach(Array(viewModel.toolViews.values)) { item in
                item.view()
            }
        }
        .frame(width: viewModel.width, height: viewModel.height)
//        .position(x: viewModel.startPosX, y: viewModel.startPosY)
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
            
            CodiChannel.BOARD_ON_ID_CHANGE.receive(on: RunLoop.main) { bId in
                self.viewModel.loadBoardSession(boardIdIn: bId as! String)
            }.store(in: &cancellables)
            
            // CodiChannel.TOOL_ON_DELETE.receive
            CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
                self.viewModel.deleteToolById(viewId: viewId as! String)
            }.store(in: &cancellables)
            
            CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
                self.viewModel.safeAddTool(id: UUID().uuidString, icon: tool as! String)
            }.store(in: &cancellables)
        }
    }
}

