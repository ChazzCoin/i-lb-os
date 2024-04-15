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
    @StateObject public var DO = OrientationInfo()
    
    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    @State public var useOriginal = false
    
    public var body: some View {
        if !NAV.masterResetNavWindow {
            if #available(iOS 16.0, *) {
                modernView
            } else {
                legacyView
            }
        }
    }
    
    @available(iOS 16.0, *)
    var modernView: some View {
        NavigationSplitView(
            columnVisibility: .constant(NAV.sidebarState.sidebar),
            sidebar: {
                NAV.getActiveView()?.getSidebarView()
            },
            detail: {
                NAV.getActiveView()?.getMainView()
                    .background(Image("sol_bg_big").opacity(0.3))
                    .environmentObject(NAV)
                    .navigationBarItems(leading: HStack {
                        // Add buttons or icons here for minimize, maximize, close, etc.
                        Button(action: {
                            NAV.mainState = .closed
                        }) {
                            Image(systemName: "minus.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                    }, trailing: HStack {
                        if self.NAV.keyboardIsShowing {
                            Button(action: {
                                hideKeyboard()
                            }) {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                        Button(action: {
                            main { NAV.toggleFloating(gps: NAV.gps) }
                        }) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    })
            })
        .frame(width: NAV.navSize.width, height: NAV.navSize.height)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NAV.mainState)
        .position(NAV.position)
        .offset(x: NAV.offPos.x + (NAV.isDragging ? NAV.dragOffset.width : 0), y: (NAV.offPos.y + (NAV.isDragging ? NAV.dragOffset.height : 0)) + NAV.keyboardHeight)
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    self.isDragging = true
                    if useOriginal {
                        NAV.originOffPos = NAV.offPos
                        useOriginal = false
                    }
                    NAV.offPos = CGPoint(
                        x: NAV.originOffPos.x + value.translation.width,
                        y: NAV.originOffPos.y + value.translation.height
                    )
                }
                .onEnded { value in
                    NAV.offPos = CGPoint(
                        x: NAV.originOffPos.x + value.translation.width,
                        y: NAV.originOffPos.y + value.translation.height
                    )
                    NAV.isDragging = false
                    useOriginal = true
                }
        )
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                
                self.NAV.keyboardIsShowing = true
                
                if height < 100 {
                    self.NAV.keyboardHeight = 0.0
                    return
                }
                if self.NAV.keyboardHeight < height {
                    self.NAV.keyboardHeight = height / 2
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                
                self.NAV.keyboardIsShowing = false
                
                if height > 100 {
                    self.NAV.keyboardHeight = 0.0
                    return
                }
                if self.NAV.keyboardHeight > height {
                    self.NAV.keyboardHeight = height * 2
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.NAV.resetNavStack(gps: NAV.gps)
                NAV.masterResetTheWindow()
            }
        })
        .onChange(of: self.NAV.mainState) { _ in
            if self.NAV.mainState.main == NavStackState.open.main {
                if self.NAV.keyboardIsShowing {
                    hideKeyboard()
                }
            }
        }
        .onAppear() {
            NAV.setSize(gps: NAV.gps, .full_menu_bar)
        }
    }
    
    var legacyView: some View {
        Group {
            NAV.getActiveView()?.getMainView()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(NAV)
                .navigationBarItems(leading: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
                    Button(action: {
                        NAV.mainState = NavStackState.closed
                    }) {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                }, trailing: HStack {
                    if self.NAV.keyboardIsShowing {
                        Button(action: {
                            hideKeyboard()
                        }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Button(action: {
                        self.NAV.toggleWindowSize(gps: NAV.gps)
                    }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                })
        }
        .frame(width: NAV.navSize.width, height: NAV.navSize.height)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NAV.mainState)
        .position(NAV.position)
        .offset(x: NAV.offPos.x + (NAV.isDragging ? NAV.dragOffset.width : 0), y: (NAV.offPos.y + (NAV.isDragging ? NAV.dragOffset.height : 0)) + NAV.keyboardHeight)
        .simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    self.isDragging = true
                    if useOriginal {
                        NAV.originOffPos = NAV.offPos
                        useOriginal = false
                    }
                    NAV.offPos = CGPoint(
                        x: NAV.originOffPos.x + value.translation.width,
                        y: NAV.originOffPos.y + value.translation.height
                    )
                }
                .onEnded { value in
                    NAV.offPos = CGPoint(
                        x: NAV.originOffPos.x + value.translation.width,
                        y: NAV.originOffPos.y + value.translation.height
                    )
                    NAV.isDragging = false
                    useOriginal = true
                }
        )
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                
                self.NAV.keyboardIsShowing = true
                
                if height < 100 {
                    self.NAV.keyboardHeight = 0.0
                    return
                }
                if self.NAV.keyboardHeight < height {
                    self.NAV.keyboardHeight = height / 2
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                
                self.NAV.keyboardIsShowing = false
                
                if height > 100 {
                    self.NAV.keyboardHeight = 0.0
                    return
                }
                if self.NAV.keyboardHeight > height {
                    self.NAV.keyboardHeight = height * 2
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NAV.resetNavStack(gps: NAV.gps)
                NAV.masterResetTheWindow()
            }
        })
        .onChange(of: self.NAV.mainState) { _ in
            if self.NAV.mainState.main == NavStackState.open.main {
                if self.NAV.keyboardIsShowing {
                    hideKeyboard()
                }
            }
        }
        .onAppear() {
            self.NAV.setSize(gps: NAV.gps, .full_menu_bar)
        }
        
    }

}


