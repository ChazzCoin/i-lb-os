//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine



public struct NavStackWindow: View {
    @EnvironmentObject public var NAV: NavWindowController
    @StateObject public var MVO = ManagedViewObject()
    @StateObject public var DO = OrientationInfo()
    @Environment(\.horizontalSizeClass) private var hSize

    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    @State public var useOriginal = false
    
    @State var visibility: NavigationSplitViewVisibility = .detailOnly

    // Prefer size-class based branching
    public var body: some View {
        Group {
            if !NAV.masterResetNavWindow {
                if hSize == .regular {
                    ModernSplitView()        // iPad / large
                } else {
                    CompactStackView()       // iPhone / compact
                }
            }
        }
        .frame(width: NAV.width, height: NAV.height)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: NAV.mainState)
        .position(NAV.position)
        .offset(
            x: NAV.offPos.x + (NAV.isDragging ? NAV.dragOffset.width : 0),
            y: (NAV.offPos.y + (NAV.isDragging ? NAV.dragOffset.height : 0)) + NAV.keyboardHeight
        )
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    main {
                        isDragging = true
                        if useOriginal {
                            NAV.originOffPos = NAV.offPos
                            useOriginal = false
                        }
                        NAV.offPos = CGPoint(
                            x: NAV.originOffPos.x + value.translation.width,
                            y: NAV.originOffPos.y + value.translation.height
                        )
                        NAV.saveDynaView()
                    }
                }
                .onEnded { value in
                    main {
                        NAV.offPos = CGPoint(
                            x: NAV.originOffPos.x + value.translation.width,
                            y: NAV.originOffPos.y + value.translation.height
                        )
                        NAV.isDragging = false
                        useOriginal = true
                        NAV.saveDynaView()
                    }
                }
        )
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

    // MARK: - iPad / Regular width
    @ViewBuilder
    private func ModernSplitView() -> some View {
        // Use a stateful visibility rather than .constant(.detailOnly)
        
        NavigationSplitView(columnVisibility: $visibility) {
            // Sidebar (only shown on iPad / regular)
            NAV.getActiveView()?.getSidebarView()
        } detail: {
            NAV.getActiveView()?.getMainView()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(NAV)
                .toolbar {
                    // Use modern toolbar placements
                    ToolbarItem(placement: .topBarLeading) {
                        Button { mainAnimation { NAV.mainState = .closed } } label: {
                            Image(systemName: "minus.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            if NAV.keyboardIsShowing {
                                Button { hideKeyboard() } label: {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                }
                            }
                            Button { mainAnimation { NAV.toggleSize() } } label: {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            }
                        }
                    }
                }
        }
        // Remove sidebar toggle only on iPad if you really don’t want it
//        .toolbar(removing: .sidebarToggle)
    }

    // MARK: - iPhone / Compact width
    @ViewBuilder
    private func CompactStackView() -> some View {
        NavigationStack {
            NAV.getActiveView()?.getMainView()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(NAV)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { mainAnimation { NAV.mainState = .closed } } label: {
                            Image(systemName: "minus.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            if NAV.keyboardIsShowing {
                                Button { hideKeyboard() } label: {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                }
                            }
                            Button { NAV.toggleWindowSize(gps: NAV.gps) } label: {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            }
                        }
                    }
                }
                // Optional: title for collapsed stacks
//                .navigationTitle(NAV.activeTitle ?? "Ludi Boards")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
