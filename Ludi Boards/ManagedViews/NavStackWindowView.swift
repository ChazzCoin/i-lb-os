//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine

struct BouncingValue {
    var value: Double
    let min: Double
    let max: Double
    private var incrementing = true
    private let step: Double

    init(initialValue: Double, min: Double, max: Double, step: Double = 0.1) {
        self.value = initialValue
        self.min = min
        self.max = max
        self.step = step
    }

    mutating func update() -> Double {
        if incrementing {
            if value < max {
                value += step
            } else {
                incrementing = false
                value -= step
            }
        } else {
            if value > min {
                value -= step
            } else {
                incrementing = true
                value += step
            }
        }
        return value
    }
}

class NavStackWindowObservable : ObservableObject {
    
    @Published var isHidden = true
    
    @Published var navStackCount = 0
    @Published var keyboardIsShowing = false
    @Published var keyboardHeight = 0.0
    
    @Published var screen: UIScreen = UIScreen.main
    @Published var width = UIScreen.main.bounds.width * 0.9
    @Published var height = UIScreen.main.bounds.height
    
    @Published var currentScreenWidthModifier = 0.9
    @Published var currentPositionModifier = 0.05
    @Published var currentScreenSize = "full" // half, float
    
    @Published var offset = CGSize.zero
    @Published var position = CGPoint(x: 0, y: 0)
    @GestureState var dragOffset = CGSize.zero
    @Published var isDragging = false
    
    func addToStack() {
        self.navStackCount = self.navStackCount + 1
    }
    func removeFromStack() {
        self.navStackCount = self.navStackCount - 1
    }
    
    func resetPosition(gps: GlobalPositioningSystem) {
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
    }
    
    func toggleWindowSize(gps: GlobalPositioningSystem) {
        if currentScreenSize == "half" {
            fullScreenPosition(gps: gps)
        } else {
            halfScreenPosition(gps: gps)
        }
    }

    func fullScreenPosition(gps: GlobalPositioningSystem) {
        width = UIScreen.main.bounds.width * 0.9
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
        currentScreenSize = "full"
    }

    func halfScreenPosition(gps: GlobalPositioningSystem) {
        width = UIScreen.main.bounds.width * 0.5
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.5)
        currentScreenSize = "half"
    }
    
}

struct NavStackWindow : View {
    @State var id: String
    var viewBuilder: () -> AnyView
    
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var gps = GlobalPositioningSystem()
    @StateObject var NavStack = NavStackWindowObservable()
    
    init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }
    
    
    @State private var isFloatable = false
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            viewBuilder()
                .background(Image("sol_bg_big").opacity(0.3))
                .environmentObject(BEO)
                .environmentObject(NavStack)
                .navigationBarItems(trailing: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
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
                        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: "close", viewId: "self"))
                    }) {
                        Image(systemName: "arrow.down.to.line.alt")
                            .resizable()
                            .frame(width: 30, height: 30)
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
        .onChange(of: self.NavStack.isHidden) { _ in
            if self.NavStack.isHidden {
                if self.NavStack.keyboardIsShowing {
                    hideKeyboard()
                }
            }
        }
        .onDisappear() {
//            fullScreenPosition()
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
                
                if temp.windowId == "master" {
                    self.NavStack.isHidden = true
                    return
                }
                
                if temp.windowId != self.id {
                    if temp.stateAction == "toggle" {
                        if !self.NavStack.isHidden {
                            self.NavStack.isHidden = true
                        }
                    }
                    return
                }
                self.NavStack.fullScreenPosition(gps: self.gps)
                if temp.stateAction == "toggle" {
                    if self.NavStack.isHidden {
                        self.NavStack.isHidden = false
                    } else {
                        
                        self.NavStack.isHidden = true
                    }
                } else if temp.stateAction == "open" {
                    self.NavStack.isHidden = false
                } else if temp.stateAction == "close" {
                    self.NavStack.isHidden = true
                }
            }.store(in: &cancellables)
        }
    }

}


struct NavStackFloatingWindow : View {
    @State var id: String
    var viewBuilder: () -> AnyView
    @EnvironmentObject var BEO: BoardEngineObject
    
    init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }
    @State var screenWidth = UIScreen.main.bounds.width
    @State var screenHeight = UIScreen.main.bounds.height
    
    @State var width = 0.0
    @State var height = 0.0

    @State var cancellables = Set<AnyCancellable>()
    @State private var isHidden = true
    
    @State private var isLocked = false
    @State var unLockedImage = "lock.open.fill"
    @State var lockedImage = "lock.fill"
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    func resetSize() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.width = min(screenWidth, screenHeight) * 0.5
        } else {
            self.width = min(screenWidth, screenHeight) * 0.8
        }
        
        self.height = min(screenWidth, screenHeight) * 0.6
    }

    var body: some View {
        NavigationStack {
            viewBuilder()
                .environmentObject(self.BEO)
                .opacity(isHidden ? 0 : 1)
                .navigationBarItems(trailing: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
                    Button(action: {
                        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: "close", viewId: "self"))
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        self.isLocked = !self.isLocked
                    }) {
                        Image(systemName: self.isLocked ? "lock.fill" : "lock.open.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                })
        }
        .frame(width: self.width, height: self.height)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .opacity(isHidden ? 0 : 1)
        .offset(x: position.x + (isDragging ? dragOffset.width : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .simultaneousGesture( self.isLocked ? nil :
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onChanged { _ in
                    self.isDragging = true
                }
                .onEnded { value in
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        )

        .onAppear() {
            resetSize()
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                let temp = wc as! WindowController
                
                if temp.windowId != self.id { return }
                
                if temp.stateAction == "toggle" {
                    if self.isHidden {
                        self.isHidden = false
                    } else {
                        self.isHidden = true
                    }
                } else if temp.stateAction == "open" {
                    self.isHidden = false
                } else if temp.stateAction == "close" {
                    self.isHidden = true
                }
            }.store(in: &cancellables)
        }
    }

}
