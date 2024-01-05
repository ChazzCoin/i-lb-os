//
//  DragAndDrop.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import RealmSwift
import Combine


struct ManagedViewBoardTool: View {
    let viewId: String
    let activityId: String
    let toolType: String
    @EnvironmentObject var BEO: BoardEngineObject
    
    @State private var color: Color = .black
    @State private var rotation = 0.0
    
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        Image(toolType)
            .resizable()
            .enableMVT(viewId: viewId, activityId: activityId)
    }
}


struct enableManagedViewTool : ViewModifier {
    @State var viewId: String
    @State var activityId: String
    @EnvironmentObject var BEO: BoardEngineObject
    
    @StateObject var commander = CommandController()
    
//    @State private var currentUserId = "iphone"
//    @State private var lastUserId = ""
//    let minSizeWH = 100.0
//
//    @State var isWriting = false
//    @State private var updateCount = 0
    @GestureState var dragOffset = CGSize.zero
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
        }
        .frame(width: self.commander.lifeWidth * 2, height: self.commander.lifeHeight * 2)
        .rotationEffect(.degrees(self.commander.lifeRotation))
        .border(self.commander.popUpIsVisible ? self.commander.lifeBorderColor : Color.clear, width: 10) // Border modifier
        .position(x: self.commander.position.x + (self.commander.isDragging ? self.dragOffset.width : 0) + (self.commander.lifeWidth),
                  y: self.commander.position.y + (self.commander.isDragging ? self.dragOffset.height : 0) + (self.commander.lifeHeight))
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onEnded { _ in
                    if self.commander.lifeIsLocked {return}
                    self.commander.isDragging = true
                }
                .sequenced(before: DragGesture())
                .updating($dragOffset, body: { (value, state, transaction) in
                    if self.commander.lifeIsLocked {return}
                    switch value {
                        case .second(true, let drag?):
                            state = drag.translation
                        self.commander.updateRealmPos(x: self.commander.position.x + drag.translation.width, y: self.commander.position.y + drag.translation.height)
                        self.commander.sendXY(width: drag.translation.width, height: drag.translation.height)
                        default:
                            break
                    }
                })
                .onEnded { value in
                    if self.commander.lifeIsLocked {return}
                    if case .second(true, let drag?) = value {
                        self.commander.position = CGPoint(x: self.commander.position.x + drag.translation.width, y: self.commander.position.y + drag.translation.height)
                        self.commander.updateRealmPos()
                        self.commander.isDragging = false
                    }
                }.simultaneously(with: TapGesture(count: 2)
                    .onEnded { _ in
                        print("Tapped")
                        self.commander.popUpIsVisible = !self.commander.popUpIsVisible
                        self.commander.toggleMenuWindow()
                        if self.commander.popUpIsVisible {
                            self.commander.sendToolAttributes()
                        }
                    }
                )
        )
        .opacity(!self.commander.isDisabledChecker() && !self.commander.isDeletedChecker() ? 1 : 0.0)
        .onAppear {
            commander.initialize(viewId: self.viewId, activityId: self.activityId)
        }
    }
    
   

    
   

}
