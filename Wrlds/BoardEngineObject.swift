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

public protocol BoardNode: Identifiable {
    var id: String {get set}
    var position: CGPoint { get }
    var size: CGSize { get }
    @ViewBuilder func render() -> AnyView
}

public struct AnyBoard: Identifiable {

    public let id: String
    private let _render: () -> AnyView

    public init<B: BoardNode>(_ board: B) {
        self.id = board.id
        self._render = board.render
    }

    public func render() -> AnyView {
        _render()
    }
}

struct WorldPoint {
    var x: CGFloat
    var y: CGFloat
}
struct CanvasCamera {
    var position: WorldPoint   // world center
    var scale: CGFloat         // zoom
    var rotation: Angle
}


public class BoardEngineObject : ObservableObject {
//    static let shared = BoardEngineObject()
    @Environment(\.colorScheme) public var colorScheme
    
    // Scene graph
    @Published public var boards: [AnyBoard] = []

    // Content refresh
    @Published public var refreshFlag: Bool = false

    public func add(_ board: AnyBoard) {
        boards.append(board)
    }

    public func remove(id: String) {
        boards.removeAll { $0.id == id }
    }

    @State public var realmInstance = realm()
    @Published public var boardRefreshFlag = true
    
    @Published public var gesturesAreLocked: Bool = false
    @Published public var isShowingPopUp: Bool = false
    
    @Published public var isSharedBoard = false
    @Published public var isLoggedIn: Bool = true
    @Published public var userId: String? = nil
    @Published public var userName: String? = nil
    // Current Board
    @Published public var showTipViewStatic: Bool = false
    @Published public var isDraw: Bool = false
    @Published public var isDrawing: String = "LINE"
    @Published public var isLoading: Bool = true
    @Published public var currentSessionId: String = ""
    @Published public var currentActivityId: String = ""
    
//    @Published var cameraPosition = Vec3(0, 0, -1500)
//    @Published var cameraRotation = Vec3(0, 0, 0)
    // pitch (x), yaw (y), roll (z)
    @Published var focalLength: CGFloat = 1000

    @Published var camera = CanvasCamera(
        position: WorldPoint(x: 0, y: 0),
        scale: 0.03,
        rotation: .zero
    )

    @Published public var canvasOffset = CGPoint.zero
    @Published public var canvasScale: CGFloat = 0.1
    @Published public var canvasRotation: CGFloat = 0.0
    @Published public var canvasAngle: Angle = Angle(degrees: 0.0)
    @GestureState public var gestureScale: CGFloat = 1.0
    @Published public var lastScaleValue: CGFloat = 1.0

    // Shared
    @Published public var isShared: Bool = false
    @Published public var isHost: Bool = true
    
    @Published public var canvasWidth: CGFloat = 8000.0
    @Published public var canvasHeight: CGFloat = 8000.0
    // Board Settings
    @Published public var boardWidth: CGFloat = 5000.0
    @Published public var boardHeight: CGFloat = 6000.0
    @Published public var boardStartPosX: CGFloat = 0.0
    @Published public var boardStartPosY: CGFloat = 1000.0
    @Published public var boardBgColor: Color = Color.green.opacity(0.75)
    
    @Published public var boardBgName: String = "SoccerFieldFullView"
    @Published public var boardBgRed: Double = 48.0
    @Published public var boardBgGreen: Double = 128.0
    @Published public var boardBgBlue: Double = 20.0
    @Published public var boardBgAlpha: Double = 0.75
    
    @Published public var boardFieldLineColor: Color = Color.white
    @Published public var boardFieldLineRed: Double = 48.0
    @Published public var boardFieldLineGreen: Double = 128.0
    @Published public var boardFieldLineBlue: Double = 20.0
    @Published public var boardFieldLineAlpha: Double = 0.75
    @Published public var boardFeildLineStroke: Double = 10
    @Published public var boardFeildRotation: Double = 0
    
    @AppStorage("toolBarPickerWindowIsVisible") public var toolBarPickerWindowIsVisible: Bool = false
    @AppStorage("boardSettingsWindowIsVisible") public var boardSettingsWindowIsVisible: Bool = false
    @AppStorage("mvSettingsWindowIsVisible") public var mvSettingsWindowIsVisible: Bool = false
    
    public var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func pan(by translation: CGSize) {
        let delta = CGSize(
            width: translation.width / camera.scale,
            height: translation.height / camera.scale
        )

        let cosR = cos(camera.rotation.radians)
        let sinR = sin(camera.rotation.radians)

        let dx = delta.width * cosR + delta.height * sinR
        let dy = -delta.width * sinR + delta.height * cosR

        camera.position.x -= dx
        camera.position.y -= dy
    }
    
    func worldToView(_ world: WorldPoint, camera: CanvasCamera) -> CGPoint {
        let translatedX = world.x - camera.position.x
        let translatedY = world.y - camera.position.y

        let cosR = cos(camera.rotation.radians)
        let sinR = sin(camera.rotation.radians)

        let rotatedX = translatedX * cosR - translatedY * sinR
        let rotatedY = translatedX * sinR + translatedY * cosR

        return CGPoint(
            x: rotatedX * camera.scale,
            y: rotatedY * camera.scale
        )
    }

    func viewToWorld(_ point: CGPoint, camera: CanvasCamera) -> WorldPoint {
        let scaledX = point.x / camera.scale
        let scaledY = point.y / camera.scale

        let cosR = cos(-camera.rotation.radians)
        let sinR = sin(-camera.rotation.radians)

        let rotatedX = scaledX * cosR - scaledY * sinR
        let rotatedY = scaledX * sinR + scaledY * cosR

        return WorldPoint(
            x: rotatedX + camera.position.x,
            y: rotatedY + camera.position.y
        )
    }

    public func navRight() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: -100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    public func navLeft() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    public func navDown() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: -100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    public func navUp() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: 100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    private func calculateAdjustedOffset(angle: CGFloat, x: CGFloat, y: CGFloat) -> CGVector {
        let dx = x * cos(angle) - y * sin(angle)
        let dy = x * sin(angle) + y * cos(angle)
        return CGVector(dx: dx, dy: dy)
    }
    public func loadUser() {
//        self.realmInstance.loadGetCurrentSolUser { su in
//            userId = su.userId
//            userName = su.userName
//            isLoggedIn = su.isLoggedIn
//        }
    }
    
    public func fullScreen() {
        canvasScale = 0.2
        canvasOffset = CGPoint.zero
        canvasRotation = 0.0
    }
    
    public func getColor() -> Color {
        return Color(red: boardBgRed, green: boardBgGreen, blue: boardBgBlue, opacity: boardBgAlpha)
    }
    
    public func getFieldLineColor() -> Color {
        return Color(red: boardFieldLineRed, green: boardFieldLineGreen, blue: boardFieldLineBlue, opacity: boardFieldLineAlpha)
    }
    
    public func setColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        boardBgRed = red
        boardBgGreen = green
        boardBgBlue = blue
        boardBgAlpha = alpha
        boardBgColor = getColor()
    }
    
}

public struct BoardView: View {

    @EnvironmentObject public var engine: BoardEngineObject

    public var body: some View {
        ZStack {
            ForEach(engine.boards) { board in
                board.render()
            }
        }
    }
}

