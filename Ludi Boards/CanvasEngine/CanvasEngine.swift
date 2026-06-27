//
//  CanvasEngine.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/8/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CoreEngine


public class CanvasEngineControl: ObservableObject {

    // Window visibility lives in-memory on purpose: @AppStorage inside an
    // ObservableObject never publishes (views gated on it would not update),
    // and persisted visibility would re-open windows across launches.
    @Published public var mvSettingsWindowIsVisible: Bool = false

    @Published public var masterResetCanvas: Bool = false
    public func masterResetTheCanvas() {
        self.masterResetCanvas = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.masterResetCanvas = false
        }
    }
}

public struct CanvasEngine: View {

    @StateObject public var CanvasControl = CanvasEngineControl()
    @StateObject public var navTools: NavWindowController = NavWindowController()
    @StateObject public var BEO = BoardEngineObject()
    // Required by SessionPlanView and friends inside the nav window.
    @StateObject public var navWindowState = NavStackWindowObservable()

    @State var storeInMenuBar = Set<AnyCancellable>()
    @State var canvasCancellables = Set<AnyCancellable>()

    @GestureState private var dragOffset = CGSize.zero
    @State public var lastOffset = CGPoint.zero

    // RD-1 scaffold (TASK-002): DEBUG-only entry to the redesigned board.
    // Shipping launch stays on this CanvasEngine; removed at RD-6 cutover.
    @State private var showRedesignBoard = false

    public var body: some View {

        GlobalPositioningZStack(coordinateSpace: .global) { windowGPS in

            // Screen layer: toolbars + floating windows
            GlobalPositioningReader(coordinateSpace: .global) { geo, gps in

                // Per-tool settings bar (opens when a tool is double-tapped)
                if CanvasControl.mvSettingsWindowIsVisible {
                    MvSettingsBar {}
                        .zIndex(3.0)
                        .position(using: gps, at: .bottomCenter, offsetY: 150)
                        .environmentObject(self.BEO)
                }

                // Drawing-mode tip banner with a stop button
                if self.BEO.isDraw {
                    TipBoxViewFlasher(tips: TipLineDrawing) {
                        self.BEO.disableDrawing()
                    }
                    .frame(width: 300)
                    .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
                    .zIndex(3.0)
                }

                // Floating nav window (Home dashboard); hidden until opened
                navTools.getNavStackView()
                    .zIndex(2.5)
                    .environmentObject(self.BEO)
                    .environmentObject(self.navWindowState)

                // Board toolbar: bottom drawer that summons itself from its
                // always-visible bottom strip
                CanvasMenuView()
                    .zIndex(2.0)
                    .environmentObject(gps)
                    .environmentObject(self.BEO)

            }.zIndex(2.0)

            // Board
            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name, width: 20000, height: 20000) { cGps in

                if !CanvasControl.masterResetCanvas {
                    BoardEngine()
                        .zIndex(0.0)
                        .environmentObject(self.BEO)
                        .environmentObject(self.navTools)
                }

            }
            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
            .zIndex(0.0)

        }
        .zIndex(1.0)
        .background(Color.black.opacity(0.0001))
        .gesture(dragAngleGestures.simultaneously(with: scaleGestures))
        .overlay(alignment: .topTrailing) { redesignDebugButton }
        .fullScreenCover(isPresented: $showRedesignBoard) {
            RedesignRootView()
                .overlay(alignment: .topLeading) {
                    Button { showRedesignBoard = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                            .padding(16)
                    }
                }
        }
        .onAppear() {
            self.lastOffset = self.BEO.canvasOffset
            addViewsToNavStack()
            BroadcastTools.listenForCanvasCalls(storeIn: &canvasCancellables, onEvent: { action in
                if action == CanvasAction.refresh {
                    self.CanvasControl.masterResetTheCanvas()
                }
                else if action == CanvasAction.closeWindows {
                    self.CanvasControl.mvSettingsWindowIsVisible = false
                }
            })
            // Tools broadcast "mvSettings" open/close on double-tap.
            // Subscribe to the channel directly: BroadcastTools' subscriber
            // debounce (0.5s) would drop a settings open/close that follows
            // another NavStackMessage too quickly.
            CodiChannel.NavStackMessage.receive(on: RunLoop.main) { msg in
                guard let message = msg as? NavStackMessage,
                      message.viewName?.lowercased() == "mvsettings" else { return }
                if message.viewAction == WindowAction.open {
                    self.CanvasControl.mvSettingsWindowIsVisible = true
                }
                else if message.viewAction == WindowAction.close {
                    self.CanvasControl.mvSettingsWindowIsVisible = false
                }
                else if message.viewAction == WindowAction.toggle {
                    self.CanvasControl.mvSettingsWindowIsVisible.toggle()
                }
            }.store(in: &storeInMenuBar)
        }
    }

    // DEBUG-only floating button that opens the redesigned board (RD-1
    // scaffold). Renders nothing in release, so the redesign entry is
    // unreachable in shipping builds until the RD-6 cutover.
    @ViewBuilder private var redesignDebugButton: some View {
        #if DEBUG
        Button { showRedesignBoard = true } label: {
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(11)
                .background(.black.opacity(0.45), in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.15)))
        }
        .padding(.top, 54)
        .padding(.trailing, 18)
        .zIndex(10)
        #else
        EmptyView()
        #endif
    }

    func addViewsToNavStack() {
        // Home: sessions, activities, teams. Local Realm only — works logged out.
        navTools.addView(
            callerId: MenuBarProvider.home.tool.title,
            mainContent: { HomeDashboardView().environmentObject(self.BEO) },
            sideContent: { MenuListView(isShowing: .constant(true)).clearSectionBackground() }
        )
    }

    var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if self.BEO.gesturesAreLocked || self.BEO.isDraw { return }

                // Counter-rotate the drag translation so panning tracks the
                // finger even when the canvas is rotated.
                let translation = gesture.translation
                let cosAngle = cos(Angle(degrees: self.BEO.canvasRotation).radians)
                let sinAngle = sin(Angle(degrees: self.BEO.canvasRotation).radians)

                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height

                let offsetX = self.lastOffset.x + (adjustedX / self.BEO.canvasScale)
                let offsetY = self.lastOffset.y + (adjustedY / self.BEO.canvasScale)
                self.BEO.canvasOffset = CGPoint(x: offsetX, y: offsetY)
            }
            .onEnded { _ in
                self.lastOffset = self.BEO.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
    }

    var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.BEO.gesturesAreLocked || self.BEO.isDraw { return }
                let delta = value / self.BEO.lastScaleValue
                self.BEO.canvasScale = min(max(self.BEO.canvasScale * delta,
                                               BoardEngineObject.minCanvasScale),
                                           BoardEngineObject.maxCanvasScale)
                self.BEO.lastScaleValue = value
            }
            .onEnded { _ in
                self.BEO.lastScaleValue = 1.0
            }
    }

}
