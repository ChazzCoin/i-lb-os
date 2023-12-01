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
    
    let firebaseService = FirebaseService(reference: Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue))
//    let reference = Database
//        .database()
//        .reference()
//        .child(DatabasePaths.managedViews.rawValue)
    @State var cancellables = Set<AnyCancellable>()
    @State private var isFirstLoad = true
    var width: CGFloat = 2400
    var height: CGFloat = 3400
    var startPosX: CGFloat = 2400 / 2
    var startPosY: CGFloat = 3400 / 2
    
    let realmInstance = realm()
    
    var counter = 0
    
    //TODO: create demo board for sharing.
    @State var boardId: String = "boardEngine-1"
    @State var boardBg = BoardBgProvider.soccerTwo.tool.image
    
    @State var isLoading = false
    @Published var toolViews: [String:ViewWrapper] = [:]
    @Published var basicTools: [ManagedView] = []
    @Published var lineTools: [ManagedView] = []
    
    @Published var isDrawing = false
    
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
        isLoading = true
        let tempBoard = realmInstance.object(ofType: BoardSession.self, forPrimaryKey: boardIdIn)
        if tempBoard == nil { return }
        toolViews.removeAll()
        toolViews = [:]
        boardId = boardIdIn
        boardBg = BoardBgProvider.parseByTitle(title: tempBoard?.backgroundImg ?? "Soccer 2")?.tool.image ?? "soccer_two"
        loadManagedViewTools()
    }
        
    func loadManagedViewTools() {
        // Dispatch work to a background thread
        DispatchQueue.global(qos: .background).async {
            self.firebaseService.startObserving(path: self.firebaseService.reference.child(self.boardId)) { snapshot in
                print("FIRE OBSERVER CALLING -> \(self.counter)")
                self.counter += 1
                let newMapped = snapshot.toHashMap()
                for (_, value) in newMapped {
                    if let tempHash = value as? [String: Any], let temp = toManagedView(dictionary: tempHash) {
//                        let _ = tempHash.toRealmObject(ManagedView.self)
                        self.basicTools.safeAdd(temp)
                    }
                }
                self.firebaseService.stopObserving()
            }
        }
    }
    
    func loadAllBoardSessions() {
        isLoading = true
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
    
    func newBasicTool(id: String, icon: String) -> ManagedViewBoardTool {
        return ManagedViewBoardTool(boardId: self.boardId, viewId: id, toolType: icon)
    }
    
}

extension Array where Element: ManagedView {
    mutating func safeAdd(_ item: ManagedView) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
}
