//
//  BoardEngineView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

struct BoardEngine: View {
    @Binding var isDraw: Bool
    @State var cancellables = Set<AnyCancellable>()
    @ObservedObject var viewModel = ViewModel()
    private let realmIntance = realm()
    
    @State var lineTools: [ManagedView] = []
    
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    
    func reloadLineTools() {
        lineTools.removeAll()
        for line in realmIntance.objects(ManagedView.self).where({ $0.toolType == "LINE" && $0.boardId == "boardEngine-1" }) {
            lineTools.append(line)
        }
    }
    
    var body: some View {
         ZStack() {
             
            ForEach(Array(viewModel.toolViews.values)) { item in
                item.view()
            }
             ForEach(lineTools) { item in
                 LineDrawingManaged(viewId: item.id)
             }
             
             // Temporary line being drawn
             if self.isDraw {
                 
                 if startPoint != .zero {  
                     Path { path in
                         path.move(to: startPoint)
                         path.addLine(to: endPoint)
                     }
                     .stroke(Color.red, lineWidth: 10)
                 }
                 
             }
            
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .background {
            Image(viewModel.boardBg)
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
        ).gesture(
            DragGesture()
                .onChanged { value in
                    if !self.isDraw {return}
                    self.startPoint = value.startLocation
                    self.endPoint = value.location
                }
                .onEnded { value in
                    if !self.isDraw {return}
                    self.endPoint = value.location
                    saveLineData(start: value.startLocation, end: value.location)
                    reloadLineTools()
                }
        ).onAppear {
            
            reloadLineTools()
            
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
    
    private func saveLineData(start: CGPoint, end: CGPoint) {
        realmIntance.safeWrite { r in
            let line = ManagedView()
            line.boardId = "boardEngine-1"
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            line.toolType = "LINE"
            line.dateUpdated = Int(Date().timeIntervalSince1970)
            r.add(line)
        }
    }
}

