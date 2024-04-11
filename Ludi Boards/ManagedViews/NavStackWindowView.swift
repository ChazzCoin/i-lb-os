//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine
import CoreEngine


struct NavStackWindow : View {
    @State var id: String
    var viewBuilder: () -> AnyView
    
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var gps = GlobalPositioningSystem()
    @StateObject var NavStack = NavStackWindowObservable()
    @StateObject var DO = OrientationInfo()
    
    init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }
    
    @State private var isFloatable = false
    @State var cancellables = Set<AnyCancellable>()
    
    @State var masterResetNavWindow = false
    func masterResetTheWindow() {
        self.masterResetNavWindow = true
        self.masterResetNavWindow = false
    }
    
    var body: some View {
        
        if !masterResetNavWindow {
            NavigationStack {
                viewBuilder()
                    .background(Image("sol_bg_big").opacity(0.3))
                    .environmentObject(BEO)
                    .environmentObject(NavStack)
                    .navigationBarItems(leading: HStack {
                        // Add buttons or icons here for minimize, maximize, close, etc.
                        Button(action: {
                            CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: "close", viewId: "self"))
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
            .frame(width: self.NavStack.width, height: self.NavStack.height)
            .opacity(self.NavStack.isHidden ? 0 : 1)
            .cornerRadius(15)
            .shadow(radius: 10)
            .position(self.NavStack.position)
            .offset(y: self.NavStack.keyboardHeight)
            .animation(.easeInOut(duration: 0.10), value: self.NavStack.isHidden)
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
                CodiChannel.MENU_WINDOW_TOGGLER.receive(on: RunLoop.main) { windowType in
                    print(windowType)
                    if (windowType as! String) != self.id { return }
                    self.NavStack.fullScreenPosition(gps: self.gps)
                    if self.NavStack.isHidden {
                        self.NavStack.isHidden = false
                    } else {
                        self.NavStack.isHidden = true
                    }
                }.store(in: &cancellables)
                
                CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                    print(wc)
                    let temp = wc as! WindowController
                    self.NavStack.fullScreenPosition(gps: self.gps)
                }.store(in: &cancellables)
            }
        }
        
        
    }

}


