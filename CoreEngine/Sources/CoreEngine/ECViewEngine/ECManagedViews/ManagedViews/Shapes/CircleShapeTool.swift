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
    
    @StateObject public var MVO: ManagedViewO = ManagedViewO(ViewEngine.Tool.ShapeTool.circle)
    @State var cancel: Set<AnyCancellable> = Set<AnyCancellable>()
    @State public var showDeleteAlert: Bool = false
    // Parameters to control sensitivity and damping
    let sensitivity: CGFloat = 0.5 // Adjust sensitivity to control speed of resizing
    let damping: CGFloat = 0.1 // Damping factor to smooth the gesture
    public var body: some View {
        
        ZStack {
            Circle()
                .stroke(colorFromRGBA(red: MVO.colorRed, green: MVO.colorGreen, blue: MVO.colorBlue, alpha: MVO.colorAlpha), style: StrokeStyle(lineWidth: Double(self.MVO.width), dash: [Double(MVO.lineDash)]))
                .frame(width: MVO.radius, height: MVO.radius)
                .position(x: MVO.x, y: MVO.y)
                .gesture(gestureDragBasicTool())
                .simultaneousGesture(doubleTapGesture())
            
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: (MVO.radius / 2).bound(to: 25...500), height: (MVO.radius / 2).bound(to: 50...200))
                .position(x: MVO.x, y: MVO.y - MVO.radius / 2)
                .gesture(anchorDragGesture(isTopAnchor: true))
                .opacity(MVO.anchorsAreVisible ? 1 : 0)
            
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: (MVO.radius / 2).bound(to: 25...500), height: (MVO.radius / 2).bound(to: 50...200))
                .position(x: MVO.x, y: MVO.y + MVO.radius / 2)
                .gesture(anchorDragGesture(isTopAnchor: false))
                .opacity(MVO.anchorsAreVisible ? 1 : 0)
        }
        .simultaneousGesture(longPressGesture())
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete Tools?", action: {
            MVO.softDeleteFromRealm()
        })
        .onAppear() {
            print("OnAppear: CircleTool.")
            MVO.loadManagedView(byId: self.viewId)
        }
        
    }
    
    public func stopListeningForSettings() {
        cancel = Set<AnyCancellable>()
    }
    
    @MainActor
    public func listenForSettings() {
        BroadcastTools.listenForWindowCalls(storeIn: &cancel, onEvent: { id, action in
            print("ID!!!!! \(id)")
            if id != "mvsettings" { return }
            if action == WindowAction.open {
                if MVO.anchorsAreVisible {
                    MVO.anchorsAreVisible = false
                    MVO.popUpIsVisible = false
                }
            }
            else if action == WindowAction.close {
                if MVO.anchorsAreVisible {
                    MVO.anchorsAreVisible = false
                    MVO.popUpIsVisible = false
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
                    if MVO.isLocked { return }
                    MVO.isDragging = true
                    if MVO.useOriginal {
                        self.MVO.oXY = MVO.position
                        self.MVO.useOriginal = false
                    }
                    let translation = drag.translation
                    MVO.position = CGPoint(x: MVO.oXY.x + translation.width,
                                           y: MVO.oXY.y + translation.height)
                    MVO.x = MVO.position.x
                    MVO.y = MVO.position.y
                    MVO.saveToRealm()
                }
            }
            .onEnded { drag in
                main {
                    self.MVO.ignoreUpdates = false
                    if MVO.isLocked { return }
                    MVO.isDragging = false
                    let translation = drag.translation
                    MVO.position = CGPoint(
                        x: MVO.oXY.x + translation.width,
                        y: MVO.oXY.y + translation.height
                    )
                    MVO.x = MVO.position.x
                    MVO.y = MVO.position.y
                    MVO.saveToRealm()
                    self.MVO.useOriginal = true
                }
            }
    }
    

    public func anchorDragGesture(isTopAnchor: Bool) -> some Gesture {
        // Parameters to control sensitivity and damping
        let sensitivity: CGFloat = 0.5 // Adjust sensitivity to control speed of resizing
        let damping: CGFloat = 0.1 // Damping factor to smooth the gesture

        return DragGesture()
            .onChanged { value in
                guard !self.MVO.isLocked, MVO.anchorsAreVisible else { return }
                self.MVO.isDragging = true
                self.MVO.ignoreUpdates = true

                // Calculate the change in the circle's radius based on drag with sensitivity
                let change = value.translation.height * sensitivity
                let newWidth = MVO.radius + (isTopAnchor ? -change : change)
                
                // Apply damping to smooth the resizing
                let smoothedWidth = (MVO.radius * (1 - damping)) + (newWidth * damping)

                // Set minimum and maximum size for the circle
                let minSize: CGFloat = 100
                let maxSize: CGFloat = 10000

                // Update the circle's width only if within bounds
                self.MVO.radius = min(max(smoothedWidth, minSize), maxSize)
                
                MVO.saveToRealm()
            }
            .onEnded { _ in
                guard !self.MVO.isLocked, MVO.anchorsAreVisible else { return }
                self.MVO.isDragging = false
                self.MVO.ignoreUpdates = false
//                MVO.updateRealm()
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
