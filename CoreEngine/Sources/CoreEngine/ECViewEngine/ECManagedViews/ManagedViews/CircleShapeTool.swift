//
//  ManagedViewToolBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import FirebaseDatabase

public struct CircleShapeManagedView: View {
    @State public var viewId: String
    @State public var activityId: String
    public init(viewId: String, activityId: String) {
        self.viewId = viewId
        self.activityId = activityId
    }
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    @State var cancel: Set<AnyCancellable> = Set<AnyCancellable>()
    @State public var showDeleteAlert: Bool = false
    // Parameters to control sensitivity and damping
    let sensitivity: CGFloat = 0.5 // Adjust sensitivity to control speed of resizing
    let damping: CGFloat = 0.1 // Damping factor to smooth the gesture
    public var body: some View {
        
        ZStack {
            Circle()
                .stroke(MVO.lifeColor, style: StrokeStyle(lineWidth: self.MVO.lifeWidth, dash: [MVO.lifeLineDash]))
                .frame(width: MVO.lifeHeight, height: MVO.lifeHeight)
                .position(MVO.position)
                .gesture(gestureDragBasicTool())
                .simultaneousGesture(doubleTapGesture())
            
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: (MVO.lifeHeight / 2).bound(to: 25...500), height: (MVO.lifeHeight / 2).bound(to: 50...200))
                .position(x: MVO.position.x, y: MVO.position.y - MVO.lifeHeight / 2)
                .gesture(anchorDragGesture(isTopAnchor: true))
                .opacity(MVO.anchorsAreVisible ? 1 : 0)
            
            Circle()
            .fill(Color.AIMYellow)
            .frame(width: (MVO.lifeHeight / 2).bound(to: 25...500), height: (MVO.lifeHeight / 2).bound(to: 50...200))
            .position(x: MVO.position.x, y: MVO.position.y + MVO.lifeHeight / 2)
            .gesture(anchorDragGesture(isTopAnchor: false))
            .opacity(MVO.anchorsAreVisible ? 1 : 0)
        }
        .simultaneousGesture(longPressGesture())
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete Tools?", action: {
            MVO.deleteTool()
        })
        .onAppear() {
            print("OnAppear: CircleTool.")
            MVO.initializeWithViewId(viewId: self.viewId)
        }
        
    }
    
    func stopListeningForSettings() {
        cancel = Set<AnyCancellable>()
    }
    
    @MainActor
    func listenForSettings() {
        BroadcastTools.listenForWindowCalls(storeIn: &cancel, onEvent: { id, action in
            print("ID!!!!! \(id)")
            if id != "mvsettings" { return }
            if action == WindowAction.open {
                if MVO.anchorsAreVisible {
                    MVO.anchorsAreVisible = false
                }
            }
            else if action == WindowAction.close {
                if MVO.anchorsAreVisible {
                    MVO.anchorsAreVisible = false
                }
            }
            else if action == WindowAction.toggle {
                return
            }
        })
    }
    
    // Gestures
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
                    MVO.updateRealmPos(start: MVO.position, end: MVO.position)
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
                    MVO.updateRealmPos(start: MVO.position, end: MVO.position)
                    self.MVO.useOriginal = true
                }
            }
//            .simultaneously(with: TapGesture(count: 2)
//                .onEnded { _ in
//                    print("Tapped")
//                    MVO.popUpIsVisible = !MVO.popUpIsVisible
//                    self.MVO.toggleMenuWindow()
//                    if MVO.popUpIsVisible {
////                        self.sendToolAttributes()
//                    }
//                }
//            )
        
    }
    

    public func anchorDragGesture(isTopAnchor: Bool) -> some Gesture {
        // Parameters to control sensitivity and damping
        let sensitivity: CGFloat = 0.5 // Adjust sensitivity to control speed of resizing
        let damping: CGFloat = 0.1 // Damping factor to smooth the gesture

        return DragGesture()
            .onChanged { value in
                guard !self.MVO.lifeIsLocked, MVO.anchorsAreVisible else { return }
                self.MVO.isDragging = true
                self.MVO.ignoreUpdates = true

                // Calculate the change in the circle's radius based on drag with sensitivity
                let change = value.translation.height * sensitivity
                let newWidth = MVO.lifeHeight + (isTopAnchor ? -change : change)
                
                // Apply damping to smooth the resizing
                let smoothedWidth = (MVO.lifeHeight * (1 - damping)) + (newWidth * damping)

                // Set minimum and maximum size for the circle
                let minSize: CGFloat = 100
                let maxSize: CGFloat = 10000

                // Update the circle's width only if within bounds
                self.MVO.lifeHeight = min(max(smoothedWidth, minSize), maxSize)
                
                MVO.updateRealm()
            }
            .onEnded { _ in
                guard !self.MVO.lifeIsLocked, MVO.anchorsAreVisible else { return }
                self.MVO.isDragging = false
                self.MVO.ignoreUpdates = false
                MVO.updateRealm()
            }
    }

    
    // Basic Gestures
    public func singleTapGesture() -> some Gesture {
        TapGesture(count: 1).onEnded({ _ in
            print("Tapped single")
         })
    }
    
    public func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
            MVO.toggleMenuWindow()
            delayThenMain(1, mainBlock: {
                if MVO.anchorsAreVisible {
                    listenForSettings()
                } else {
                    stopListeningForSettings()
                }
            })
            
         })
    }
    
    // TODO: This should be delete...
    public func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.showDeleteAlert = true
       }
    }
    
}
