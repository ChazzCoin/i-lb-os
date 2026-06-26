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


@ViewBuilder
public func EmptyText(text:String="") -> some View { Text(text) }
@ViewBuilder
public func EmptyIcon(systemName: String = "exclamationmark.triangle.fill", imageName:String?=nil) -> some View {
    if let imgName = imageName { Image(imgName).resizable() } else { Image(systemName: systemName).resizable() }
}

public struct BasicToolView: View {
    
    public var subType: String
    
    public var body: some View {
        Image(subType)
            .resizable()
    }
}

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

public struct ManagedViewTool<C: View>: View {
    @ViewBuilder public var content: () -> C
    public let viewId: String
    public let activityId: String
    public var bounds: CGRect? = nil
    
    public init(viewId: String, activityId: String="", bounds: CGRect? = nil, @ViewBuilder contentIn: @escaping () -> C) {
        self.viewId = viewId
        self.activityId = activityId
        self.bounds = bounds
        self.content = contentIn
    }

    public var body: some View {
        content()
            .enableManagedViewBasic(viewId: viewId, activityId: activityId, bounds: self.bounds)
    }
}

public struct enableManagedViewTool : ViewModifier {
    
    @State public var viewId: String
    @State public var activityId: String
    
    public let bounds: CGRect?
    
    public init(viewId: String, activityId: String="", bounds: CGRect?=nil) {
        self.viewId = viewId
        self.activityId = activityId
        self.bounds = bounds
        print(self.bounds as Any)
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
        // Redesign selection ring (TASK-004): a lime ring on the selected tool,
        // replacing the legacy blue debug border. Keyed on the shared
        // `selectedManagedViewId` so it tracks engine selection.
        .overlay {
            if MVO.selectedManagedViewId == viewId {
                // Line widths are in the tool's local space (the board renders at
                // ~0.1 scale), so they must be bold to read on screen.
                Circle()
                    .stroke(Color(hex: "CBDB2A"), lineWidth: max(24, MVO.lifeWidth * 0.22))
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "CBDB2A").opacity(0.22),
                                    lineWidth: max(40, MVO.lifeWidth * 0.4))
                            .padding(-max(20, MVO.lifeWidth * 0.2))
                    )
                    .allowsHitTesting(false)
            }
        }
        .position(x: MVO.position.x + (MVO.isDragging ? dragOffset.width : 0) + (MVO.lifeWidth),
                  y: MVO.position.y + (MVO.isDragging ? dragOffset.height : 0) + (MVO.lifeHeight))
        
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .highPriorityGesture(gestureDragBasicTool())
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId { MVO.popUpIsVisible = false }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing { MVO.popUpIsVisible = false }
        })
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete Tools?", action: {
            MVO.deleteTool()
        })
        .onAppear {
            print("OnAppear: BasicTool.")
            print("Loading Tool: \(viewId), \(activityId)")
//            print("Loading Pos: \(MVO.lifeStartX), \(MVO.lifeStartY)")
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
                    let temp = CGPoint(x: MVO.originalPosition.x + translation.width,
                                           y: MVO.originalPosition.y + translation.height)
                    if let bounds = self.bounds {
                        let clampped = clamp(position: temp, to: bounds)
                        MVO.position = clampped
                    } else {
                        MVO.position = temp
                    }
                    MVO.updateRealmPos(start: MVO.position, end: MVO.position)
                    BroadcastTools.send(.Canvas, value: NodeStream(id: self.viewId, position: MVO.position))
                }
            }
            .onEnded { drag in
                main {
                    self.MVO.ignoreUpdates = false
                    if MVO.lifeIsLocked { return }
                    MVO.isDragging = false
                    let translation = drag.translation
                    let temp = CGPoint(
                        x: MVO.originalPosition.x + translation.width,
                        y: MVO.originalPosition.y + translation.height
                    )
                    if let bounds = self.bounds {
                        let clampped = clamp(position: temp, to: bounds)
                        MVO.position = clampped
                    } else {
                        MVO.position = temp
                    }
                    MVO.updateRealmPos(start: MVO.position, end: MVO.position)
                    self.MVO.useOriginal = true
                    BroadcastTools.send(.Canvas, value: NodeStream(id: self.viewId, position: MVO.position))
                }
            }
            .simultaneously(with: TapGesture(count: 2)
                .onEnded { _ in
                    print("Tapped Twice")
                    MVO.popUpIsVisible = !MVO.popUpIsVisible
                    MVO.anchorsAreVisible = !MVO.anchorsAreVisible
                    self.MVO.toggleMenuWindow()
                    delayThenMain(1, mainBlock: {
                        if MVO.anchorsAreVisible {
                            MVO.listenForSettings()
                        } else {
                            MVO.cancel = Set<AnyCancellable>()
                        }
                    })
                }
            )
            .simultaneously(with: LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in
                    print("Long Press")
                    MVO.showDeleteAlert = true
                }
            )
        
    }
    
    
    
    
}
