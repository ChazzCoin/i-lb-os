//
//  BoardEngineVM.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI
import Combine
import FirebaseDatabase
import RealmSwift

class ViewModel: ObservableObject {
    
    let reference = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    @State var cancellables = Set<AnyCancellable>()
    
    var width: CGFloat = 2400
    var height: CGFloat = 3400
    var startPosX: CGFloat = 2400 / 2
    var startPosY: CGFloat = 3400 / 2
    
    let realmInstance = realm()
    
    //TODO: create demo board for sharing.
    @State var boardId: String = "boardEngine-1"
    @State var boardBg = Image("soccer_one")
    // flowData
    
    @Published var toolViews: [String:ViewWrapper] = [:]
    
    init() { 
        loadAllBoardSessions()
    }
    
    func deleteToolById(viewId:String) {
        realmInstance.safeWrite { r in
            let temp = r.findByField(ManagedView.self, field: "boardId", value: viewId)
            guard let t = temp else {return}
            r.delete(t)
        }
        
    }
    
    func loadBoardSession(boardIdIn:String) {
        let tempBoard = realmInstance.object(ofType: BoardSession.self, forPrimaryKey: boardIdIn)
        if tempBoard == nil { return }
        toolViews.removeAll()
        toolViews = [:]
        boardId = boardIdIn
//        boardBg.value = BoardBackgroundProvider.fromString(tempBoard.backgroundImg ?: "Soccer 1").res
        loadManagedViewTools()
    }
        
    func loadManagedViewTools() {
        reference.child(self.boardId).fireObserver { snapshot in
            let mapped = snapshot.toHashMap()
            if mapped.count < self.toolViews.count { self.toolViews = [:] }
            for (itId, value) in mapped {
                if let tempHash = value as? [String: Any] {
                    let temp: ManagedView? = toManagedView(dictionary: tempHash)
                    if let itTemp = temp {
                        self.safeAddTool(id: itId, icon: temp?.toolType ?? SoccerToolProvider.playerDummy.tool.title)
                    }
                }
            }
        }
    }
    
    func loadAllBoardSessions() {
        let boardList = realmInstance.objects(BoardSession.self)
        var bId = ""
        if boardList.isEmpty {
            try! realmInstance.write {
                let newBoard = BoardSession()
                realmInstance.add(newBoard)
                bId = newBoard.id
            }
        } else {
            let temp = boardList.first
            bId = temp?.id ?? "test"
        }
        loadBoardSession(boardIdIn: bId)
        print("BOARDS: initial load -> ${boardList.size}")
    }
    func newTool(id: String, icon: String) -> ViewWrapper {
        return ViewWrapper{AnyView(ManagedViewBoardTool(boardId: self.boardId, viewId: id, toolType: icon))}
    }
    func safeAddTool(id: String, icon: String) {
        guard toolViews[id] != nil else {
            let parsedTool = SoccerToolProvider.parseByTitle(title: icon)?.tool.image ?? SoccerToolProvider.playerDummy.tool.image
            toolViews[id] = newTool(id: id, icon: parsedTool)
            return
        }
    }
}

