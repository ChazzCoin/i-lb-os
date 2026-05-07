//
//  NodeStackWindow.swift
//  CoreEngine
//
//  Created by Charles Romeo on 2/3/26.
//

//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine


public struct NodeStackWindow: View {
    @State public var id: String
    
    public init(id: String) { self.id = id }
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    @EnvironmentObject public var NAV: NodeWindowController
    @StateObject public var DO = OrientationInfo()
    @Environment(\.horizontalSizeClass) private var hSize

    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    @State public var useOriginal = false
    
    @State var visibility: NavigationSplitViewVisibility = .detailOnly

    // Prefer size-class based branching
    public var body: some View {
        NavigationStack {
            NAV.getActiveView()?.getMainView()
                .environmentObject(NAV)
        }
        
//        .frame(width: NAV.width, height: NAV.height)
        .border(.blue, width: 1)
//        .enableManagedViewBasic(viewId: self.id, activityId: self.currentRoomId)
        .keyboardListener(
            onAppear: { height in
                mainAnimation {
                    NAV.keyboardIsShowing = true
                    if height < 100 { NAV.keyboardHeight = 0.0; return }
                    if NAV.keyboardHeight < height { NAV.keyboardHeight = height / 2 }
                }
            },
            onDisappear: { height in
                mainAnimation {
                    NAV.keyboardIsShowing = false
                    if height > 100 { NAV.keyboardHeight = 0.0; return }
                    if NAV.keyboardHeight > height { NAV.keyboardHeight = height * 2 }
                }
            }
        )
        .onAppear {
            NAV.resetNavStack(gps: NAV.gps)
            NAV.masterResetTheWindow()
        }
        
        .onChange(of: DO.orientation) { _ in
            delayThenMain(0.5) {
                NAV.resetNavStack(gps: NAV.gps)
                NAV.masterResetTheWindow()
            }
        }
        .onChange(of: NAV.mainState) { _ in
            if NAV.mainState.main == NavStackState.open.main, NAV.keyboardIsShowing {
                hideKeyboard()
            }
        }
    }

}
