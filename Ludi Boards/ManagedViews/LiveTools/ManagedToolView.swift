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
import CoreEngine


// Tool Bar Picker Icon View
struct ManagedViewBasicToolIcon: View {
    let toolType: String
    
    @State private var color: Color = .black
    @State private var rotation = 0.0

    var body: some View {
        Image(toolType)
            .resizable()
    }
}


// Main Board Tool View
struct ManagedViewBasicTool: View {
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
            .enableManagedViewBasic(viewId: viewId, activityId: activityId)
    }
}

extension View {
    func enableManagedViewBasic(viewId: String, activityId: String) -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, activityId: activityId))
    }
}

struct enableManagedViewTool : ViewModifier {
    
    @State var viewId: String
    @State var activityId: String
    
    @StateObject var MVO: ManagedViewObject = ManagedViewObject()
    @GestureState public var dragOffset = CGSize.zero
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
        }
        .zIndex(MVO.isDisabled || MVO.lifeIsLocked ? 3.0 : 5.0)
        .frame(width: MVO.lifeWidth * 2, height: MVO.lifeHeight * 2)
        .rotationEffect(MVO.lifeRotation)
        .border(MVO.popUpIsVisible ? MVO.lifeBorderColor : Color.clear, width: 10) // Border modifier
        .position(x: MVO.position.x + (MVO.isDragging ? dragOffset.width : 0) + (MVO.lifeWidth),
                  y: MVO.position.y + (MVO.isDragging ? dragOffset.height : 0) + (MVO.lifeHeight))
        .simultaneousGesture(gestureDragBasicTool())
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId { MVO.popUpIsVisible = false }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing { MVO.popUpIsVisible = false }
        })
        .onAppear {
            self.MVO.initializeWithViewId(viewId: viewId)
        }
    }
    
    func gestureDragBasicTool() -> some Gesture {
        DragGesture()
            .onChanged { drag in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = true }
                if MVO.lifeIsLocked { return }
                MVO.isDragging = true
                if MVO.useOriginal {
                    self.MVO.originalPosition = MVO.position
                    self.MVO.useOriginal = false
                }
                let translation = drag.translation
                MVO.position = CGPoint(x: MVO.originalPosition.x + translation.width,
                                       y: MVO.originalPosition.y + translation.height)
                MVO.updateRealmPos(x: MVO.originalPosition.x + translation.width,
                                              y: MVO.originalPosition.y + translation.height)
//                self.sendXY(width: translation.width, height: translation.height)
            }
            .onEnded { drag in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = false }
                if MVO.lifeIsLocked { return }
                MVO.isDragging = false
                let translation = drag.translation
                MVO.position = CGPoint(
                    x: MVO.originalPosition.x + translation.width,
                    y: MVO.originalPosition.y + translation.height
                )
                self.MVO.updateRealm()
                self.MVO.useOriginal = true
            }.simultaneously(with: TapGesture(count: 2)
                .onEnded { _ in
                    print("Tapped")
                    MVO.popUpIsVisible = !MVO.popUpIsVisible
                    self.MVO.toggleMenuWindow()
                    if MVO.popUpIsVisible {
//                        self.sendToolAttributes()
                    }
                }
            )
        
    }
    
    
    
    
}
