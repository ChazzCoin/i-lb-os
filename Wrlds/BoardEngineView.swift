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

class BoardEngineObject : ObservableObject {
//    static let shared = BoardEngineObject()
    @Environment(\.colorScheme) var colorScheme

    @State var realmInstance = realm()
    @Published var boardRefreshFlag = true
    
    @Published var gesturesAreLocked: Bool = false
    @Published var isShowingPopUp: Bool = false
    
    @Published var isSharedBoard = false
    @Published var isLoggedIn: Bool = true
    @Published var userId: String? = nil
    @Published var userName: String? = nil
    // Current Board
    @Published var showTipViewStatic: Bool = false
    @Published var isDraw: Bool = false
    @Published var isDrawing: String = "LINE"
    @Published var isLoading: Bool = true
    @Published var currentSessionId: String = ""
    @Published var currentActivityId: String = ""
    
    @Published var canvasOffset = CGPoint.zero
    @Published var canvasScale: CGFloat = 0.1
    @Published var canvasRotation: CGFloat = 0.0
    @GestureState var gestureScale: CGFloat = 1.0
    @Published var lastScaleValue: CGFloat = 1.0

    
    // Shared
    @Published var isShared: Bool = false
    @Published var isHost: Bool = true
    
    @Published var canvasWidth: CGFloat = 8000.0
    @Published var canvasHeight: CGFloat = 8000.0
    // Board Settings
    @Published var boardWidth: CGFloat = 5000.0
    @Published var boardHeight: CGFloat = 6000.0
    @Published var boardStartPosX: CGFloat = 0.0
    @Published var boardStartPosY: CGFloat = 1000.0
    @Published var boardBgColor: Color = Color.green.opacity(0.75)
    
    @Published var boardBgName: String = "SoccerFieldFullView"
    @Published private var boardBgRed: Double = 48.0
    @Published private var boardBgGreen: Double = 128.0
    @Published private var boardBgBlue: Double = 20.0
    @Published var boardBgAlpha: Double = 0.75
    
    @Published var boardFieldLineColor: Color = Color.white
    @Published var boardFieldLineRed: Double = 48.0
    @Published var boardFieldLineGreen: Double = 128.0
    @Published var boardFieldLineBlue: Double = 20.0
    @Published var boardFieldLineAlpha: Double = 0.75
    @Published var boardFeildLineStroke: Double = 10
    @Published var boardFeildRotation: Double = 0
    
    func navRight() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: -100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navLeft() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navDown() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: -100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navUp() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: 100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    private func calculateAdjustedOffset(angle: CGFloat, x: CGFloat, y: CGFloat) -> CGVector {
        let dx = x * cos(angle) - y * sin(angle)
        let dy = x * sin(angle) + y * cos(angle)
        return CGVector(dx: dx, dy: dy)
    }
    func loadUser() {
//        self.realmInstance.loadGetCurrentSolUser { su in
//            userId = su.userId
//            userName = su.userName
//            isLoggedIn = su.isLoggedIn
//        }
    }
    
    func fullScreen() {
        canvasScale = 0.2
        canvasOffset = CGPoint.zero
        canvasRotation = 0.0
    }
    
    func getColor() -> Color {
        return Color(red: boardBgRed, green: boardBgGreen, blue: boardBgBlue, opacity: boardBgAlpha)
    }
    
    func getFieldLineColor() -> Color {
        return Color(red: boardFieldLineRed, green: boardFieldLineGreen, blue: boardFieldLineBlue, opacity: boardFieldLineAlpha)
    }
    
    func setColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        boardBgRed = red
        boardBgGreen = green
        boardBgBlue = blue
        boardBgAlpha = alpha
        boardBgColor = getColor()
    }
    
}

struct BoardEngine: View {
    
    @EnvironmentObject var BEO: BoardEngineObject
    
    @State var cancellables = Set<AnyCancellable>()
    
    @State private var realmIntance = realm()
    @State private var reference: DatabaseReference = Database.database().reference()
    @State private var observerHandle: DatabaseHandle?
    
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var activityNotificationToken: NotificationToken? = nil
    @State private var managedViewNotificationToken: NotificationToken? = nil
   
    
    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    

    
    func refreshBoard() {
        self.BEO.boardRefreshFlag = false
        self.BEO.boardRefreshFlag = true
    }
    
    var body: some View {
         ZStack() {
             
             Text("under the bunk radio")
                 .font(.system(size: 1000))
                 .frame(maxWidth: .infinity)
                 .position(CGPoint(x: 15000.0, y: -5000.0))
             
             if self.BEO.boardRefreshFlag {
                 MusicPlayerView()
                     .frame(width: 500, height: 500)
                     .scaleEffect(7.0)
                     .background(Color.white)
//                     .position()
             }
//             
//             NavStackFloatingWindow(id: "new", viewBuilder: {
//                 UserLoginSignupView()
////                     .frame(width: 500, height: 500)
////                     .scaleEffect(7.0)
//                     
//             })
//             .frame(width: 500, height: 500)
//             .scaleEffect(7.0)
//             .position(CGPoint(x: 15000.0, y: -2000.0))
             
             
        }
        .frame(width: self.BEO.boardWidth, height: self.BEO.boardHeight)
//        .background(
//            UtbBgOne()
//        )
        .onDrop(of: [.text], isTargeted: nil) { providers in
            providers.first?.loadObject(ofClass: NSString.self) { (droppedString, error) in
                
            }
            return true
        }
        .onAppear {
            
        }
    }
    
}

