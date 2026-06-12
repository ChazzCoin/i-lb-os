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
            x: NAV.offPos.x,
            y: NAV.offPos.y - NAV.keyboardHeight
        )
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    main {
                        if useOriginal {
                            NAV.originOffPos = NAV.offPos
                            useOriginal = false
                        }
                        NAV.offPos = CGPoint(
                            x: NAV.originOffPos.x + value.translation.width,
                            y: NAV.originOffPos.y + value.translation.height
                        )
                        // No Realm write mid-drag — persisted once in onEnded.
                    }
                }
                .onEnded { value in
                    main {
                        NAV.offPos = CGPoint(
                            x: NAV.originOffPos.x + value.translation.width,
                            y: NAV.originOffPos.y + value.translation.height
                        )
                        useOriginal = true
                        NAV.saveDynaView()
                    }
                }
        )
        .keyboardListener(
            onAppear: { height in
                mainAnimation {
                    NAV.keyboardIsShowing = true
                    NAV.keyboardHeight = keyboardOverlap(keyboardFrameHeight: height)
                }
            },
            onDisappear: { _ in
                mainAnimation {
                    NAV.keyboardIsShowing = false
                    NAV.keyboardHeight = 0.0
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

    // True overlap (in points) between the window's bottom edge and the
    // keyboard's top edge. Shift the window up by exactly this much —
    // replaces the old device-specific height/2 and height*2 guesses.
    // NOTE: keyboard avoidance is runtime/device-sensitive; verify on
    // a physical device across iPhone/iPad and floating positions.
    private func keyboardOverlap(keyboardFrameHeight: CGFloat) -> CGFloat {
        guard keyboardFrameHeight > 1 else { return 0 }
        let screenH = NAV.gps.effectiveSize.height
        let windowBottom = NAV.position.y + NAV.offPos.y + (NAV.height / 2)
        let keyboardTop = screenH - keyboardFrameHeight
        return max(0, windowBottom - keyboardTop)
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
                .id(NAV.activeView?.id)
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
                .id(NAV.activeView?.id)
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
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
