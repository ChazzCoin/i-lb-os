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
import FirebaseDatabase

struct BoardEngine: View {
    @Binding var isDraw: Bool
    @State var cancellables = Set<AnyCancellable>()
    
    let realmIntance = realm()
    
    let firebaseService = FirebaseService(reference: Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue))
    
    //Board
    var width: CGFloat = 2400
    var height: CGFloat = 3400
    var startPosX: CGFloat = 2400 / 2
    var startPosY: CGFloat = 3400 / 2
    
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    
    @State private var boardId: String = "boardEngine-1"
    @State private var boardBg = BoardBgProvider.soccerTwo.tool.image
    
    @State private var isLoading = false
    @State private var toolViews: [String:ViewWrapper] = [:]
    @State private var basicTools: [ManagedView] = []
    @State private var lineTools: [ManagedView] = []
    
    
    var body: some View {
         ZStack() {
             
             ForEach(self.basicTools) { item in
                 if item.toolType == "LINE" {
                     LineDrawingManaged(viewId: item.id).zIndex(3.0)
                 } else {
                     if let temp = SoccerToolProvider.parseByTitle(title: item.toolType)?.tool.image {
                         ManagedViewBoardTool(boardId: item.boardId, viewId: item.id, toolType: temp)
                     }
                 }
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
        .frame(width: width, height: height)
        .background {
            Image(boardBg)
                .resizable()
                .aspectRatio(contentMode: .fill) // Fill the area, possibly cropping the image
                .frame(width: width, height: height) // Match the frame size of the ZStack
                .position(x: startPosX, y: startPosY)
        }
        .overlay(
            Rectangle() // The rectangle that acts as the border
                .stroke(Color.red, lineWidth: 2) // Red border with a stroke width of 2
                .frame(width: width, height: height)
                .position(x: startPosX, y: startPosY)
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
                }
        ).onAppear {
            self.loadAllBoardSessions()
            
            CodiChannel.BOARD_ON_ID_CHANGE.receive(on: RunLoop.main) { bId in
                self.boardId = bId as! String
                self.loadBoardSession()
            }.store(in: &cancellables)
            
            // CodiChannel.TOOL_ON_DELETE.receive
            CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
                self.deleteToolById(viewId: viewId as! String)
            }.store(in: &cancellables)
            
            CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
                let newTool = ManagedView()
                newTool.toolType = tool as! String
                newTool.boardId = self.boardId
                realmIntance.safeWrite { r in
                    r.add(newTool)
                }
                firebaseDatabase { fdb in
                    fdb.child(DatabasePaths.managedViews.rawValue)
                        .child(self.boardId)
                        .child(newTool.id)
                        .setValue(newTool.toDictionary())
                }
                
            }.store(in: &cancellables)
        }
    }
    
    func loadAllBoardSessions() {
        isLoading = true
        let boardList = self.realmIntance.objects(BoardSession.self)
        self.boardId = "boardEngine-1"
        if boardList.isEmpty {
            self.realmIntance.safeWrite { r in
                let newBoard = BoardSession()
                newBoard.id = self.boardId
                r.add(newBoard)
            }
        } else {
            let temp = boardList.first
            if temp?.id != nil && !temp!.id.isEmpty {
                self.boardId = temp?.id ?? "boardEngine-1"
            }
        }
        loadBoardSession()
        print("BOARDS: initial load -> ${boardList.size}")
    }
    
    func loadBoardSession() {
        isLoading = true
        let tempBoard = self.realmIntance.findByField(BoardSession.self, field: "id", value: self.boardId)
        if tempBoard == nil { return }
        toolViews.removeAll()
        toolViews = [:]
        boardBg = BoardBgProvider.parseByTitle(title: tempBoard?.backgroundImg ?? "Soccer 2")?.tool.image ?? "soccer_two"
        loadManagedViewTools()
    }
    
    func loadManagedViewTools() {
        // Dispatch work to a background thread
        self.firebaseService.startObserving(path: self.firebaseService.reference.child(self.boardId)) { snapshot in
            print("FIRE OBSERVER CALLING")
            let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmIntance)
            let newMapped = snapshot.toHashMap()
            for (_, value) in newMapped {
                if let tempHash = value as? [String: Any], let temp = toManagedView(dictionary: tempHash) {
                    self.basicTools.safeAdd(temp)
                }
            }
//            self.firebaseService.stopObserving()
        }
    }
    
    func deleteToolById(viewId:String) {
        self.realmIntance.safeWrite { r in
            let temp = r.findByField(ManagedView.self, field: "boardId", value: viewId)
            guard let t = temp else {return}
            r.delete(t)
        }
        
    }
    
    // Line/Drawing
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
            firebaseDatabase { fdb in
                fdb.child(DatabasePaths.managedViews.rawValue)
                    .child(self.boardId)
                    .child(line.id)
                    .setValue(line.toDictionary())
            }
        }
    }
}

