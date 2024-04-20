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
    
    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    @State public var useOriginal = false
    
    public var body: some View {
        if !NAV.masterResetNavWindow {
            if #available(iOS 17.0, *) {
                modernView
            } else {
                legacyView
            }
        }
    }
    
    @available(iOS 17.0, *)
    public var modernView: some View {
        NavigationSplitView(
            columnVisibility: .constant(.detailOnly),
            sidebar: {
                NAV.getActiveView()?.getSidebarView().toolbar(removing: NAV.sidebarIsEnabled ? .none : .sidebarToggle)
            },
            detail: {
                NAV.getActiveView()?.getMainView()
                    .background(Image("sol_bg_big").opacity(0.3))
                    .environmentObject(NAV)
                    .navigationBarItems(leading: HStack {
                            EmptyView()
                        }, trailing: HStack {
                        Button(action: { mainAnimation {NAV.mainState = .closed} }) {
                            Image(systemName: "minus.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        if self.NAV.keyboardIsShowing {
                            Button(action: { hideKeyboard() }) {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                        Button(action: { mainAnimation { NAV.toggleSize() } }) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    })
            })
        .zIndex(40)
        .toolbar(removing: .sidebarToggle)
        .frame(width: NAV.width, height: NAV.height)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NAV.mainState)
        .position(NAV.position)
        .offset(
            x: NAV.offPos.x + (NAV.isDragging ? NAV.dragOffset.width : 0),
            y: (NAV.offPos.y + (NAV.isDragging ? NAV.dragOffset.height : 0)) + NAV.keyboardHeight
        )
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    main {
                        self.isDragging = true
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
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                mainAnimation {
                    self.NAV.keyboardIsShowing = true
                    if height < 100 { self.NAV.keyboardHeight = 0.0; return }
                    if self.NAV.keyboardHeight < height { self.NAV.keyboardHeight = height / 2 }
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                mainAnimation {
                    self.NAV.keyboardIsShowing = false
                    if height > 100 { self.NAV.keyboardHeight = 0.0; return }
                    if self.NAV.keyboardHeight > height { self.NAV.keyboardHeight = height * 2 }
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            delayThenMain(0.5) {
                self.NAV.resetNavStack(gps: NAV.gps)
                NAV.masterResetTheWindow()
            }
        })
        .onChange(of: self.NAV.mainState) { _ in
            if self.NAV.mainState.main == NavStackState.open.main {
                if self.NAV.keyboardIsShowing { hideKeyboard() }
            }
        }
    }
    
    public var legacyView: some View {
        NavigationView {
            NAV.getActiveView()?.getMainView()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(NAV)
                .navigationBarItems(leading: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
                    Button(action: { mainAnimation { NAV.mainState = NavStackState.closed } }) {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                }, trailing: HStack {
                    if self.NAV.keyboardIsShowing {
                        Button(action: { hideKeyboard() }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Button(action: { self.NAV.toggleWindowSize(gps: NAV.gps) }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                })
        }
        .frame(width: NAV.width, height: NAV.height)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NAV.mainState)
        .position(NAV.position)
        .offset(x: NAV.offPos.x + (NAV.isDragging ? NAV.dragOffset.width : 0), y: (NAV.offPos.y + (NAV.isDragging ? NAV.dragOffset.height : 0)) + NAV.keyboardHeight)
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    main {
                        self.isDragging = true
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
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                mainAnimation {
                    self.NAV.keyboardIsShowing = true
                    if height < 100 { self.NAV.keyboardHeight = 0.0; return }
                    if self.NAV.keyboardHeight < height { self.NAV.keyboardHeight = height / 2 }
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                mainAnimation {
                    self.NAV.keyboardIsShowing = false
                    if height > 100 { self.NAV.keyboardHeight = 0.0; return }
                    if self.NAV.keyboardHeight > height { self.NAV.keyboardHeight = height * 2 }
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            delayThenMain(0.5) {
                NAV.resetNavStack(gps: NAV.gps)
                NAV.masterResetTheWindow()
            }
        })
        .onChange(of: self.NAV.mainState) { _ in
            if self.NAV.mainState.main == NavStackState.open.main {
                if self.NAV.keyboardIsShowing { hideKeyboard() }
            }
        }
    }

}


