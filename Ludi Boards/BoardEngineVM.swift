//
//  BoardEngineVM.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI
import Combine

class ViewModel: ObservableObject {
    
    @State var cancellables = Set<AnyCancellable>()
    
    var width: CGFloat = 2400
    var height: CGFloat = 3400
    var startPosX: CGFloat = 2400 / 2
    var startPosY: CGFloat = 3400 / 2
    
    let realmInstance = realm()
    @State var boardId: String = "boardEngine-1"
    @State var boardBg = Image("soccer_one")
    // flowData
    
    @Published var toolViews: [String:ViewWrapper] = [
        "test": ViewWrapper{AnyView(ManagedViewBoardTool(boardId: "", viewId: "", toolType: ""))}
    ]
    
    init() { 
        initializeFlows()
    }
    
    func initializeFlows() {
        loadAllBoardSessions()
        initRealmFlows()
        initToolClickFlow()
        
        CodiChannel.BOARD_ON_ID_CHANGE.receive(on: RunLoop.main) { bId in
            self.loadBoardSession(boardIdIn: bId as! String)
        }.store(in: &cancellables)
        
        // CodiChannel.TOOL_ON_DELETE.receive
        CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
            self.deleteToolById(viewId: viewId as! String)
        }.store(in: &cancellables)
        
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
        initRealmFlows()
    }
    func loadManagedViewTools() {
        let all = realmInstance.findAllByField(ManagedView.self, field: "boardId", value: boardId)
        print("Board Tools Size = [ ${all.size} ]")
        all?.forEach { it in safeAddTool(id: it.id, icon: it.toolType) }
    }
    
    func initRealmFlows() {}
    
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
            toolViews[id] = newTool(id: id, icon: icon)
            return
        }
    }
    func initToolClickFlow() {
        CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
            self.safeAddTool(id: UUID().uuidString, icon: tool as! String)
        }.store(in: &cancellables)
        
    }
    
}

struct BoardEngine: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        
        ZStack(){
            ForEach(Array(viewModel.toolViews.values)) { item in
                item.view()
            }
            ManagedViewBoardTool(boardId: "", viewId: "", toolType: "")
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .position(x: viewModel.startPosX, y: viewModel.startPosY)
        .zIndex(1)
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

//struct MView: View {
//    
//    @State private var position = CGPoint(x: 50, y: 50)
//    @GestureState private var dragOffset = CGSize.zero
//    
//    let data: String = ""
//
//    var body: some View {
//        Rectangle()
//            .fill(Color.black)
//            .frame(width: 300, height: 300)
//            // Use the updated position here, adding the drag offset while dragging
//            .position(x: position.x, y: position.y)
//            .zIndex(15)
//            .contentShape(Rectangle())
//            .gesture(
//                DragGesture()
//                    .updating($dragOffset, body: { (value, state, transaction) in
//                        state = value.translation
//                    })
//                    .onChanged { value in
//                        // Update the position state when the drag ends
//                        self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
//                    }
//                    .onEnded { value in
//                        // Update the position state when the drag ends
//                        self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
//                    }
//            )
//    }
//}

// Define a wrapper for your view closures
struct ViewWrapper: Identifiable {
    let id: UUID
    let viewClosure: () -> AnyView

    init(id: UUID = UUID(), viewClosure: @escaping () -> AnyView) {
        self.id = id
        self.viewClosure = viewClosure
    }

    func view() -> AnyView {
        viewClosure()
    }
}
