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

struct NavStackWindow : View {
    @State var id: String
    var viewBuilder: () -> AnyView
    @EnvironmentObject var BEO: BoardEngineObject
    
    init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }
    
    @State private var isHidden = true
    @State private var isFloatable = false
    
    @State var cancellables = Set<AnyCancellable>()
    @State var screen: UIScreen = UIScreen.main
    @State var gps = GlobalPositioningSystem()
        
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    @State private var width = UIScreen.main.bounds.width * 0.9
    @State private var height = UIScreen.main.bounds.height
    
    @State private var keyboardIsShowing = false
    @State private var keyboardHeight = 0.0
    
    @State var currentScreenWidthModifier = 0.9
    @State var currentPositionModifier = 0.05
    @State var currentScreenSize = "full" // half, float
    
    func toggleWindowSize() {
        if currentScreenSize == "half" {
            fullScreenPosition()
        } else {
            halfScreenPosition()
        }
    }
    
    func fullScreenPosition() {
        width = UIScreen.main.bounds.width * 0.9
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
        currentScreenSize = "full"
    }
    
    func halfScreenPosition() {
        width = UIScreen.main.bounds.width * 0.5
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.5)
        currentScreenSize = "half"
    }
    
    func resetPosition() {
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
    }

    var body: some View {
        NavigationStack {
            viewBuilder()
                .environmentObject(BEO)
                .navigationBarItems(trailing: HStack {
                    // Add buttons or icons here for minimize, maximize, close, etc.
                    Button(action: {
                        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.id, stateAction: "close", viewId: "self"))
                    }) {
                        Image(systemName: "arrow.down.to.line.alt")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        toggleWindowSize()
                    }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                })
        }
        .frame(width: self.width, height: self.height)
        .opacity(isHidden ? 0 : 1)
        .background(Color.clear)
        .cornerRadius(15)
        .shadow(radius: 10)
        .position(position)
        .offset(y: keyboardHeight)
        .animation(.easeInOut(duration: 1.0), value: isHidden)
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                if height < 100 {
                    keyboardHeight = 0.0
                    return
                }
                if keyboardHeight < height {
                    keyboardHeight = height / 2
                }
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                if height > 100 {
                    keyboardHeight = 0.0
                    return
                }
                if keyboardHeight > height {
                    keyboardHeight = height * 2
                }
            }
        )
        .onDisappear() {
            fullScreenPosition()
        }
        .onAppear() {
            fullScreenPosition()
//            resetPosition()
            CodiChannel.MENU_WINDOW_TOGGLER.receive(on: RunLoop.main) { windowType in
                print(windowType)
                if (windowType as! String) != self.id { return }
                fullScreenPosition()
                if self.isHidden {
                    self.isHidden = false
                } else {
                    self.isHidden = true
                }
            }.store(in: &cancellables)
            
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                print(wc)
                let temp = wc as! WindowController
                if temp.windowId != self.id {
                    if temp.stateAction == "toggle" {
                        if !self.isHidden {
                            self.isHidden = true
                        }
                    }
                    return
                }
                fullScreenPosition()
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
