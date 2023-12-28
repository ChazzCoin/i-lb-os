//
//  MvPopup.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/12/23.
//

import Foundation
import SwiftUI
import Combine

class PopupMenuObject: ObservableObject {
    @Published var viewId = ""
    
    @Published var activityId = ""
    
    @Published var viewSize: CGFloat = 50
    @Published var viewRotation: Double = 0
    @Published var viewColor: Color = .black
    @Published var toolLevel: Int = ToolLevels.BASIC.rawValue
    
    @Published var showColor = false
    @Published var isShowing = false
    @Published var isLoading = false
    @Published var showCompletion = false
    
    @Published var showSizeOption = false
    @Published var showDeleteOption = false
    @Published var showLockOption = false
    
    @Published var position = CGPoint(x: 100, y: 100)
    @GestureState var dragOffset = CGSize.zero
    @Published var isDragging = false
}

struct PopupMenuView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var PMO: PopupMenuObject
    @Binding var isPresented: Bool
    
    @State var isHidden: Bool = true
   
    @State var realmInstance = realm()
    @State var cancellables = Set<AnyCancellable>()

    func animateOptionsIn() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) { self.PMO.showLockOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.25)) { self.PMO.showDeleteOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) { self.PMO.showSizeOption = true }
    }
    
    func animateOptionsOut() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) { self.PMO.showLockOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.25)) { self.PMO.showDeleteOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) { self.PMO.showSizeOption = false }
    }

    var body: some View {
        
        VStack(spacing: 1) {
            if self.PMO.showSizeOption {
                MenuOptionSlider(label: "Size", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId)
            }
            if self.PMO.showDeleteOption {
                MenuOptionButton(label: "Delete", imageName: "trash") {
                    if let temp = self.realmInstance.findByField(ManagedView.self, value: self.PMO.viewId) {
                        self.realmInstance.safeWrite { r in
                            temp.isDeleted = true
                        }
                    }
                }
            }
            if self.PMO.showLockOption {
                MenuCheckBoxButton(label: "Unlocked", imageName: "lock") { isChecked in
                    if let temp = self.realmInstance.findByField(ManagedView.self, value: self.PMO.viewId) {
                        self.realmInstance.safeWrite { r in
                            temp.isLocked = isChecked
                        }
                    }
                }
            }
        }
        .zIndex(5.0)
        .scaleEffect(6.0)
        .frame(width: 1000, height: 1000)
        .background(Color.clear)
        .opacity(isHidden ? 0.0 : 1.0)
        .cornerRadius(15)
        .shadow(radius: 10)
        .position(x: self.PMO.position.x, y: self.PMO.position.y + 800)
        .onAppear() {
            
            animateOptionsIn()
//            self.BEO.gesturesAreLocked = true
            
            onFollow()
            onCreate()
            onWindowToggle()
        }
        .onDisappear() {
            self.BEO.gesturesAreLocked = false
            animateOptionsOut()
        }
        
    }
    
    func onFollow() {
        CodiChannel.TOOL_ON_FOLLOW.receive(on: RunLoop.main) { viewFollow in
            let vf = viewFollow as! ViewFollowing
            print("Monitoring View: X: \(vf.x) Y: \(vf.y) ")
            self.PMO.viewId = vf.viewId
            self.PMO.position = CGPoint(x: vf.x, y: vf.y)
        }.store(in: &cancellables)
    }
    
    func onCreate() {
        CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
            let temp = vId as! ViewAtts
            if temp.viewId != self.PMO.viewId {
                self.PMO.viewId = temp.viewId
                isHidden = false
            }
            if self.PMO.toolLevel != temp.level {
                self.PMO.toolLevel = temp.level
                if self.PMO.toolLevel == ToolLevels.BASIC.rawValue {self.PMO.showColor = false}
                else if self.PMO.toolLevel == ToolLevels.LINE.rawValue {self.PMO.showColor = true}
            }
            if let ts = temp.size { self.PMO.viewSize = ts }
            if let tr = temp.rotation { self.PMO.viewRotation = tr }
            if let tc = temp.color { self.PMO.viewColor = tc }
        }.store(in: &cancellables)
    }
    
    func onWindowToggle() {
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
            let temp = wc as! WindowController
            if temp.windowId != "pop_settings" { return }
            
            if let tx = temp.x {
                if let ty = temp.y {
                    self.PMO.position = CGPoint(x: tx, y: ty)
                }
            }
            
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
    
    func closeSession() {
        let va = ViewAtts(viewId: self.PMO.viewId, stateAction: "close")
        CodiChannel.TOOL_ATTRIBUTES.send(value: va)
    }
    
    func closeWindow() {
        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "pop_settings", stateAction: "close", viewId: self.PMO.viewId))
    }
    
    private func dragGesture(for positionBinding: Binding<CGPoint>) -> some Gesture {
        DragGesture()
            .onChanged { value in
                positionBinding.wrappedValue = value.location
            }
    }
}

/**
 
 x2 = (x1 / scaleFactorA) * scaleFactorB
 y2 = (y1 / scaleFactorA) * scaleFactorB

 */


struct MenuOptionButton: View {
    let label: String
    let imageName: String
    let onClick: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(label)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(foregroundColorForScheme(colorScheme))
        .cornerRadius(8)
        .scaleEffect(0.8) // Enhanced scale effect
        .onTapAnimation {
            onClick()
        }
    }
}

struct MenuCheckBoxButton: View {
    let label: String
    let imageName: String
    let onClick: (Bool) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isChecked: Bool = false

    var body: some View {
        HStack {
//            Text(label)
            Toggle(label, isOn: $isChecked)
                .labelsHidden() // Hide the label of the Toggle
                .onTapGesture {
                    isChecked.toggle() // Toggle the state of the checkbox
                    onClick(isChecked) // Call the onClick closure with the new state
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(foregroundColorForScheme(colorScheme))
        .cornerRadius(8)
        .scaleEffect(0.8) // Enhanced scale effect
    }
}

struct MenuOptionSlider: View {
    let label: String
    let imageName: String
    let viewId: String
    @Environment(\.colorScheme) var colorScheme
    @State var viewRotation: Double = 0

    var body: some View {
        Slider(
            value: $viewRotation,
            in: 0...360,
            step: 45,
            onEditingChanged: { editing in
                if !editing {
                    let va = ViewAtts(viewId: viewId, rotation: viewRotation)
                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                }
            }
        ).padding()
        
        .frame(maxWidth: 200, maxHeight: 50)
        .background(foregroundColorForScheme(colorScheme))
        .cornerRadius(8)
        .scaleEffect(1.0) // Enhanced scale effect
    }
}
