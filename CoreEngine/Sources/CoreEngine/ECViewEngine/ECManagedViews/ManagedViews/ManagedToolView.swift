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


// Tool Bar Picker Icon View
public struct ManagedViewBasicToolIcon: View {
    public let toolType: String
    
    @State public var color: Color = .black
    @State public var rotation = 0.0
    
    public init(toolType: String, color: Color = .black, rotation: Double = 0.0) {
        self.toolType = toolType
        self.color = color
        self.rotation = rotation
    }

    public var body: some View {
        Image(toolType)
            .resizable()
    }
}


// Main Board Tool View
public struct ManagedViewBasicTool: View {
    public let viewId: String
    public let activityId: String
    public let toolType: String
    
    public init(viewId: String, activityId: String="", toolType: String) {
        self.viewId = viewId
        self.activityId = activityId
        self.toolType = toolType
    }

    public var body: some View {
        Image(toolType)
            .resizable()
            .enableManagedViewBasic(viewId: viewId, activityId: activityId)
    }
}

public struct enableManagedViewTool : ViewModifier {
    
    @State public var viewId: String
    @State public var activityId: String
    
    public init(viewId: String, activityId: String="") {
        self.viewId = viewId
        self.activityId = activityId
    }
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    @GestureState public var dragOffset = CGSize.zero
    
    public func body(content: Content) -> some View {
        GeometryReader { geo in
            content
        }
        .zIndex(MVO.isDisabled || MVO.lifeIsLocked ? 3.0 : 5.0)
        .frame(width: MVO.lifeWidth * 2, height: MVO.lifeHeight * 2)
        .rotationEffect(MVO.lifeRotation)
        .border(MVO.popUpIsVisible ? MVO.lifeBorderColor : Color.clear, width: 10) // Border modifier
        .position(x: MVO.position.x + (MVO.isDragging ? dragOffset.width : 0) + (MVO.lifeWidth),
                  y: MVO.position.y + (MVO.isDragging ? dragOffset.height : 0) + (MVO.lifeHeight))
        
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .simultaneousGesture(gestureDragBasicTool())
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId { MVO.popUpIsVisible = false }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing { MVO.popUpIsVisible = false }
        })
        .onAppear {
            print("OnAppear: BasicTool.")
            self.MVO.initializeWithViewId(viewId: viewId)
        }
    }
    
    public func gestureDragBasicTool() -> some Gesture {
        DragGesture()
            .onChanged { drag in
                main {
                    self.MVO.ignoreUpdates = true
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
                }
            }
            .onEnded { drag in
                main {
                    self.MVO.ignoreUpdates = false
                    if MVO.lifeIsLocked { return }
                    MVO.isDragging = false
                    let translation = drag.translation
                    MVO.position = CGPoint(
                        x: MVO.originalPosition.x + translation.width,
                        y: MVO.originalPosition.y + translation.height
                    )
                    self.MVO.updateRealm()
                    self.MVO.useOriginal = true
                }
            }
            .simultaneously(with: TapGesture(count: 2)
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
