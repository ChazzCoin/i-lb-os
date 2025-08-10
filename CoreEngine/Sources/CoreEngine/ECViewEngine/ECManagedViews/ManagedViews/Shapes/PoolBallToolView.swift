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

public enum PoolBallType: Int, CaseIterable {
    case solid1 = 1, solid2, solid3, solid4, solid5, solid6, solid7
    case stripe9 = 9, stripe10, stripe11, stripe12, stripe13, stripe14, stripe15
    case eightBall = 8
    case que = 0
    
    public var color: Color {
        switch self {
        case .que: return .white
        case .solid1, .stripe9:
            return .yellow
        case .solid2, .stripe10:
            return .blue
        case .solid3, .stripe11:
            return .red
        case .solid4, .stripe12:
            return .purple
        case .solid5, .stripe13:
            return .orange
        case .solid6, .stripe14:
            return .green
        case .solid7, .stripe15:
            return .purple.opacity(0.75)
        case .eightBall:
            return .black
        }
    }
    
    public var stripeColor: Color {
        return self.rawValue > 8 ? .white : .clear
    }
    
    public var number: Int {
        return self.rawValue
    }
}

public struct PoolBallIcon: View {
    @State public var ballType: ViewEngine.Tool.PoolBallTool
    
    public init(ballType: ViewEngine.Tool.PoolBallTool) {
        self.ballType = ballType
    }
    
    let width: Double = 30.0
    let height: Double = 30.0

    public var body: some View {
        
        ZStack {
            if ballType.number > 8 {
                Circle()
                    .fill(.white)
                    .frame(width: width, height: height)
                Circle()
                    .fill(ballType.color)
                    .frame(width: width, height: height)
                    .mask({
                        if ballType.number > 8 {
                            // Add a stripe for striped balls
                            Rectangle()
                                .fill(.white)
                                .frame(height: 25)
                        }
                    })
                    .overlay(
                        VStack {
                            Circle()
                                .fill(.white)
                                .frame(width: width / 2, height: height / 2)
                                .overlay(
                                    Text("\(ballType.number)")
                                        .font(.system(size: 3))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                    )
            }
            else if ballType == ViewEngine.Tool.PoolBallTool.que {
                Circle()
                    .fill(.white)
                    .frame(width: width, height: height)
            }
            else {
                Circle()
                    .fill(ballType.color)
                    .frame(width: width, height: height)
                    .overlay(
                        VStack {
                            Circle()
                                .fill(.white)
                                .frame(width: width / 2, height: height / 2)
                                .overlay(
                                    Text("\(ballType.number)")
                                        .font(.system(size: 3))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                    )
            }
        }
    }
}


public struct PoolBallManagedView: View {
    @State public var viewId: String
    @State public var activityId: String
    @State public var ballType: PoolBallType
    
    public init(viewId: String, activityId: String, ballType: PoolBallType) {
        self.viewId = viewId
        self.activityId = activityId
        self.ballType = ballType
    }
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    @State var cancel: Set<AnyCancellable> = Set<AnyCancellable>()
    @State public var showDeleteAlert: Bool = false

    public var body: some View {
        
        ZStack {
            if ballType.rawValue > 8 {
                Circle()
                    .fill(.white)
                    .frame(width: 300, height: 300)
                    .position(MVO.position)
                    .gesture(gestureDragBasicTool())
                    .simultaneousGesture(doubleTapGesture())
                Circle()
                    .fill(ballType.color)
                    .frame(width: 300, height: 300)
                    .mask({
                        if ballType.rawValue > 8 {
                            // Add a stripe for striped balls
                            Rectangle()
                                .fill(.white)
                                .frame(height: 200)
                        }
                    })
                    .overlay(
                        VStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Text("\(ballType.number)")
                                        .font(.system(size: 100))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                    )
                    .position(MVO.position)
                    .gesture(gestureDragBasicTool())
                    .simultaneousGesture(doubleTapGesture())
            } 
            else if ballType == PoolBallType.que {
                Circle()
                    .fill(.white)
                    .frame(width: 300, height: 300)
                    .position(MVO.position)
                    .gesture(gestureDragBasicTool())
                    .simultaneousGesture(doubleTapGesture())
            }
            else {
                Circle()
                    .fill(ballType.color)
                    .frame(width: 300, height: 300)
                    .overlay(
                        VStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Text("\(ballType.number)")
                                        .font(.system(size: 100))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                    )
                    .position(MVO.position)
                    .gesture(gestureDragBasicTool())
                    .simultaneousGesture(doubleTapGesture())
            }
            
            
        }
        .simultaneousGesture(longPressGesture())
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete Tools?", action: {
            MVO.deleteTool()
        })
        .onAppear() {
            print("OnAppear: CircleTool.")
            MVO.initializeWithViewId(viewId: self.viewId)
            MVO.lifeHeight = 200
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
