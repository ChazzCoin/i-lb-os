//
//  BoardEngineView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase
import CoreEngine

struct BoardEngineById: View {
    
    @State var currentActivityId: String = ""
    
    @Environment(\.scenePhase) var deviceState
    
    @EnvironmentObject var managedWindowsObject: NavWindowController
    @StateObject var PMO = PopupMenuObject()
    @ObservedObject public var MVEngine: ManagedViewEngine = ManagedViewEngine()

    @State var cancellables = Set<AnyCancellable>()
    // Canvas Settings
    @State var canvasWidth: CGFloat = 8000.0
    @State var canvasHeight: CGFloat = 8000.0
    @State var canvasOffset = CGPoint(x: 6000, y: 6000)
    @State var canvasScale: CGFloat = 0.1
    @State var canvasRotation: CGFloat = 0.0
    @GestureState var gestureScale: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    // Board Settings
    @State var boardWidth: CGFloat = 5000.0
    @State var boardHeight: CGFloat = 6000.0
    @State var boardStartPosX: CGFloat = 0.0
    @State var boardStartPosY: CGFloat = 1000.0
    @State var boardBgColor: Color = Color.secondaryBackground
    @State var boardBgName: String = "Sol"
    @State var boardBgRed: Double = 48.0
    @State var boardBgGreen: Double = 128.0
    @State var boardBgBlue: Double = 20.0
    @State var boardBgAlpha: Double = 0.75
    @State var boardFieldLineColor: Color = Color.white
    @State var boardFieldLineRed: Double = 48.0
    @State var boardFieldLineGreen: Double = 128.0
    @State var boardFieldLineBlue: Double = 20.0
    @State var boardFieldLineAlpha: Double = 0.75
    @State var boardFeildLineStroke: Double = 10
    @State var boardFeildRotation: Double = 0
    
    let realmInstance: Realm = newRealm()
    let boards = Sports()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                 // Board Tools
                MVEngine.Display(reset: .constant(false))
            }
            .frame(width: self.boardWidth, height: self.boardHeight)
            .background(
                FieldOverlayView(width: self.canvasWidth, height: self.canvasHeight, background: {self.boardBgColor},
                    overlay: {
                        if let CurrentBoardBackground = self.boards.getAllBoards()[self.boardBgName] {
                            CurrentBoardBackground()
                                .zIndex(2.0)
//                                .environmentObject(self.BEO)
                        }
                    })
            )
        }
        .onAppear {
            self.threeLoadActivityPlan()
        }
    }
    
    func threeLoadActivityPlan() {

        // LOAD SINGLE ACTIVITY
        if !self.currentActivityId.isEmpty {
                       
            if let act = self.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.currentActivityId) {
                boardBgRed = act.backgroundRed
                boardBgGreen = act.backgroundGreen
                boardBgBlue = act.backgroundBlue
                boardBgAlpha = act.backgroundAlpha
                if let cIn = Color(red: act.backgroundLineRed, green: act.backgroundLineGreen, blue: act.backgroundLineBlue).opacity(act.backgroundLineAlpha).toRGBA() {
                    boardFieldLineRed = cIn.red
                    boardFieldLineGreen = cIn.green
                    boardFieldLineBlue = cIn.blue
                    boardFieldLineAlpha = cIn.alpha
//                    boardFieldLineColor = getFieldLineColor()
                }
                self.boardBgName = act.backgroundView
                self.boardFeildRotation = act.backgroundRotation
                self.boardFeildLineStroke = act.backgroundLineStroke
                
            }
            return
        }
        
    }
    
    
}

