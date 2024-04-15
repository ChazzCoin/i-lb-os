//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine


public class NavStackFactory {
    
    public static func BuildNavStackWindow<Content: View, SideBar: View>(
        caller: String="master",
        isFloatable: Bool = false,
        @ViewBuilder _ content: @escaping () -> Content,
        @ViewBuilder _ sideBar: @escaping () -> SideBar
    ) -> some View {
        return NavStackWindow(id: caller, isFloatable: isFloatable, contentBuilder: { content() }, sideBarBuilder: { content() })
    }
    
}

public struct NavStackWindow<Content: View, SideBar: View> : View {
    @State public var id: String
    @State public var isFloatable = false
    @ViewBuilder public var contentBuilder: () -> Content
    @ViewBuilder public var sideBarBuilder: () -> SideBar
    
    @State public var title: String = "Ludi Window"
    @State public var windowId: String = "Ludi Window"
    
    @StateObject public var gps = GlobalPositioningSystem()
    @StateObject public var NavStack = NavStackWindowObservable()
    @StateObject public var DO = OrientationInfo()
    
    public init(id: String="master", @ViewBuilder contentBuilder: @escaping () -> Content, @ViewBuilder sideBarBuilder: @escaping () -> SideBar={EmptyView()}) {
        self.id = id
        self.contentBuilder = contentBuilder
        self.sideBarBuilder = sideBarBuilder
        self.windowId = id
    }
    
    public init(id: String, isFloatable: Bool, @ViewBuilder contentBuilder: @escaping () -> Content, @ViewBuilder sideBarBuilder: @escaping () -> SideBar={EmptyView()}) {
        self.id = id
        self.isFloatable = isFloatable
        self.contentBuilder = contentBuilder
        self.sideBarBuilder = sideBarBuilder
        self.windowId = id
    }
    
    @State public var cancellables = Set<AnyCancellable>()
    @State public var masterResetNavWindow = false
    public func masterResetTheWindow() {
        self.masterResetNavWindow = true
        self.masterResetNavWindow = false
    }
    
    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    @State public var useOriginal = false
    
    public var body: some View {
        
        if !masterResetNavWindow {
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
            columnVisibility: .constant(.automatic),
            sidebar: {
                sideBarBuilder()
            },
            detail: {
                contentBuilder()
                    .background(Image("sol_bg_big").opacity(0.3))
                    .environmentObject(NavStack)
                    .navigationBarItems(leading: HStack {
                        // Add buttons or icons here for minimize, maximize, close, etc.
                        Button(action: {
                            CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: .close, viewId: "self"))
                        }) {
                            Image(systemName: "minus.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                    }, trailing: HStack {
                        if self.NavStack.keyboardIsShowing {
                            Button(action: {
                                hideKeyboard()
                            }) {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                        Button(action: {
//                            self.NavStack.toggleWindowSize(gps: self.gps)
                            main {
                                self.isFloatable.toggle()
                                if !self.isFloatable {
                                    self.NavStack.fullScreenPosition(gps: self.gps)
//                                    self.NavStack.toggleWindowSize(gps: self.gps)
                                }
                            }
                            
                        }) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    })
            })
        .frame(width: isFloatable ? NavStack.fWidth : NavStack.width, height: isFloatable ? NavStack.fHeight : NavStack.height)
        .opacity(self.NavStack.isHidden ? 0 : 1)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NavStack.isHidden)
        .position(NavStack.position)
        .offset(x: NavStack.offPos.x + (NavStack.isDragging ? NavStack.dragOffset.width : 0), y: (NavStack.offPos.y + (NavStack.isDragging ? NavStack.dragOffset.height : 0)) + NavStack.keyboardHeight)
        .simultaneousGesture( NavStack.isLocked || !isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    self.isDragging = true
                    if useOriginal {
                        NavStack.originOffPos = NavStack.offPos
                        useOriginal = false
                    }
                    NavStack.offPos = CGPoint(
                        x: NavStack.originOffPos.x + value.translation.width,
                        y: NavStack.originOffPos.y + value.translation.height
                    )
                }
                .onEnded { value in
                    NavStack.offPos = CGPoint(
                        x: NavStack.originOffPos.x + value.translation.width,
                        y: NavStack.originOffPos.y + value.translation.height
                    )
                    NavStack.isDragging = false
                    useOriginal = true
                }
        )
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                
                self.NavStack.keyboardIsShowing = true
                
                if height < 100 {
                    self.NavStack.keyboardHeight = 0.0
                    return
                }
                if self.NavStack.keyboardHeight < height {
                    self.NavStack.keyboardHeight = height / 2
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                
                self.NavStack.keyboardIsShowing = false
                
                if height > 100 {
                    self.NavStack.keyboardHeight = 0.0
                    return
                }
                if self.NavStack.keyboardHeight > height {
                    self.NavStack.keyboardHeight = height * 2
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.NavStack.resetNavStack(gps: self.gps)
                self.masterResetTheWindow()
            }
        })
        .onChange(of: self.NavStack.isHidden) { _ in
            if self.NavStack.isHidden {
                if self.NavStack.keyboardIsShowing {
                    hideKeyboard()
                }
            }
        }
        .onAppear() {
            self.NavStack.fullScreenPosition(gps: self.gps)
//            CodiChannel.MENU_WINDOW_TOGGLER.receive(on: RunLoop.main) { windowType in
//                print(windowType)
//                if (windowType as! String) != self.id { return }
//                self.NavStack.fullScreenPosition(gps: self.gps)
//                if self.NavStack.isHidden {
//                    self.NavStack.isHidden = false
//                } else {
//                    self.NavStack.isHidden = true
//                }
//            }.store(in: &cancellables)
//            
//            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
//                print(wc)
////                let temp = wc as! WindowController
//                self.NavStack.fullScreenPosition(gps: self.gps)
//            }.store(in: &cancellables)
        }
        
        
    }
    
    var legacyView: some View {
        Group {
            contentBuilder()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(NavStack)
                .navigationBarItems(leading: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
                    Button(action: {
                        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: .close, viewId: "self"))
                    }) {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                }, trailing: HStack {
                    if self.NavStack.keyboardIsShowing {
                        Button(action: {
                            hideKeyboard()
                        }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Button(action: {
                        self.NavStack.toggleWindowSize(gps: self.gps)
                    }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                })
        }
        .frame(width: isFloatable ? NavStack.fWidth : NavStack.width, height: isFloatable ? NavStack.fHeight : NavStack.height)
        .opacity(self.NavStack.isHidden ? 0 : 1)
        .cornerRadius(15)
        .shadow(radius: 10)
        .animation(.easeInOut(duration: 0.10), value: self.NavStack.isHidden)
        .position(NavStack.position)
        .offset(x: NavStack.offPos.x + (NavStack.isDragging ? NavStack.dragOffset.width : 0), y: (NavStack.offPos.y + (NavStack.isDragging ? NavStack.dragOffset.height : 0)) + NavStack.keyboardHeight)
        .simultaneousGesture( NavStack.isLocked || !isFloatable ? nil :
            DragGesture()
                .onChanged { value in
                    self.isDragging = true
                    if useOriginal {
                        NavStack.originOffPos = NavStack.offPos
                        useOriginal = false
                    }
                    NavStack.offPos = CGPoint(
                        x: NavStack.originOffPos.x + value.translation.width,
                        y: NavStack.originOffPos.y + value.translation.height
                    )
                }
                .onEnded { value in
                    NavStack.offPos = CGPoint(
                        x: NavStack.originOffPos.x + value.translation.width,
                        y: NavStack.originOffPos.y + value.translation.height
                    )
                    NavStack.isDragging = false
                    useOriginal = true
                }
        )
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                
                self.NavStack.keyboardIsShowing = true
                
                if height < 100 {
                    self.NavStack.keyboardHeight = 0.0
                    return
                }
                if self.NavStack.keyboardHeight < height {
                    self.NavStack.keyboardHeight = height / 2
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                
                self.NavStack.keyboardIsShowing = false
                
                if height > 100 {
                    self.NavStack.keyboardHeight = 0.0
                    return
                }
                if self.NavStack.keyboardHeight > height {
                    self.NavStack.keyboardHeight = height * 2
                }
            }
        )
        .onChange(of: self.DO.orientation, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.NavStack.resetNavStack(gps: self.gps)
                self.masterResetTheWindow()
            }
        })
        .onChange(of: self.NavStack.isHidden) { _ in
            if self.NavStack.isHidden {
                if self.NavStack.keyboardIsShowing {
                    hideKeyboard()
                }
            }
        }
        .onAppear() {
            self.NavStack.fullScreenPosition(gps: self.gps)
//            CodiChannel.MENU_WINDOW_TOGGLER.receive(on: RunLoop.main) { windowType in
//                print(windowType)
//                if (windowType as! String) != self.id { return }
//                self.NavStack.fullScreenPosition(gps: self.gps)
//                if self.NavStack.isHidden {
//                    self.NavStack.isHidden = false
//                } else {
//                    self.NavStack.isHidden = true
//                }
//            }.store(in: &cancellables)
//            
//            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
//                print(wc)
////                let temp = wc as! WindowController
//                self.NavStack.fullScreenPosition(gps: self.gps)
//            }.store(in: &cancellables)
        }
        
    }

}


