//
//  MvPopup.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/12/23.
//

import Foundation
import SwiftUI
import Combine

/*
    - Basic
        Delete, Lock, Size, Rotation
 
    - Line
        Delete, Lock, Stroke, Color
 */

class PopupMenuObject: ObservableObject {
    @Published var viewId = ""
    
    @Published var activityId = ""
    
    @Published var viewSize: CGFloat = 50
    @Published var viewRotation: Double = 0
    @Published var viewColor: Color = .black
    @Published var toolType: String = "Basic"
    @Published var toolLevel: Int = ToolLevels.BASIC.rawValue
    
    @Published var showColor = false
    @Published var isShowing = false
    @Published var isLoading = false
    @Published var showCompletion = false
    
    @Published var position = CGPoint(x: 100, y: 100)
    @GestureState var dragOffset = CGSize.zero
    @Published var isDragging = false
}

struct PopupMenuView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var PMO: PopupMenuObject
    @Binding var isPresented: Bool
    
    @State var viewRotation: Double = 0.0
    @State var viewSize: Double = 0.0
    @State var viewColor: Color = .black
    @State var viewStroke: Double = 0.0
    @State var viewIsLocked: Bool = false
    
    @State var showRotationOption = false
    @State var showSizeOption = false
    @State var showStrokeOption = false
    @State var showColorOption = false
    @State var showDeleteOption = false
    @State var showLockOption = false
    
    @State var isHidden: Bool = true
   
    @State var realmInstance = realm()
    @State var cancellables = Set<AnyCancellable>()

    func animateOptionsIn() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.60)) { self.showLockOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.50)) { self.showDeleteOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) { self.showStrokeOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.30)) { self.showColorOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.20)) { self.showSizeOption = true }
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) { self.showRotationOption = true }
        
    }
    
    func animateOptionsOut() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) { self.showLockOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.20)) { self.showDeleteOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.30)) { self.showStrokeOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) { self.showColorOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.50)) { self.showSizeOption = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.60)) { self.showRotationOption = false }
        
    }

    var body: some View {
        
        VStack(spacing: 1) {
            
            // BASIC -> Rotation
            if self.PMO.toolType == "Basic" {
                MenuOptionRotation(label: "Rotation", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId, viewRotation: $viewRotation)
            }
            
            // BASIC -> Size
            if self.PMO.toolType == "Basic" {
                MenuOptionSize(label: "Size", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId, viewSize: $viewSize)
            }
            
            // LINE -> Color
            if self.PMO.toolType == "Line" {
                MenuOptionColor(label: "Color", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId, viewColor: $viewColor)
            }
            
            // LINE -> Stroke
            if self.PMO.toolType == "Line" {
                MenuOptionStroke(label: "Stroke", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId, lineStroke: $viewStroke)
            }
            
            // ALL -> Delete
            if self.showDeleteOption {
                MenuOptionButton(label: "Delete", imageName: "trash") {
                    if let temp = self.realmInstance.findByField(ManagedView.self, value: self.PMO.viewId) {
                        self.realmInstance.safeWrite { r in
                            temp.isDeleted = true
                        }
                    }
                }
            }
            
            // ALL -> Lock
            if self.showLockOption {
                MenuCheckBoxButton(label: "Unlocked", imageName: "lock", isChecked: $viewIsLocked) { isChecked in
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
        .frame(width: 2000, height: 3000)
        .background(Color.clear)
        .opacity(isHidden ? 0.0 : 1.0)
        .cornerRadius(15)
        .shadow(radius: 10)
        .position(x: self.PMO.position.x, y: self.PMO.position.y + 1000)
        .onAppear() {
            
            animateOptionsIn()
            
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
            if self.PMO.viewId != vf.viewId {return}
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
            if let tt = temp.toolType { self.PMO.toolType = tt }
            if let ts = temp.size { self.viewSize = ts }
            if let tr = temp.rotation { self.viewRotation = tr }
            if let tc = temp.color { self.viewColor = tc }
            if let tc = temp.stroke { self.viewStroke = tc }
            if let tp = temp.position { self.PMO.position = tp }
            if let tl = temp.isLocked { self.viewIsLocked = tl }
            
        }.store(in: &cancellables)
    }
    
    func onWindowToggle() {
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
            let temp = wc as! WindowController
            
            if temp.windowId != "pop_settings" || temp.viewId != self.PMO.viewId { return }
            
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
    
    func loadFromRealm() {
        
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.PMO.viewId)
        guard let umv = mv else { return }
        // set attributes
        let _ = umv.boardId
        viewIsLocked = umv.isLocked
    
        self.PMO.toolType = umv.toolType == "LINE" || umv.toolType == "CURVED-LINE" ? "Line" : "Basic"
        
        viewSize = Double(umv.width)
        viewStroke = Double(umv.lineDash)
        viewRotation = umv.rotation
        viewColor = colorFromRGBA(red: umv.colorRed, green: umv.colorGreen, blue: umv.colorBlue, alpha: umv.colorAlpha)
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
        .frame(maxWidth: 200, maxHeight: 50)
        .background(getForegroundColor(colorScheme))
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
    @Binding var isChecked: Bool
    let onClick: (Bool) -> Void
    @Environment(\.colorScheme) var colorScheme
    

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
        .frame(maxWidth: 200, maxHeight: 50)
        .background(getForegroundColor(colorScheme))
        .cornerRadius(8)
        .scaleEffect(0.8) // Enhanced scale effect
    }
}

struct MenuOptionRotation: View {
    let label: String
    let imageName: String
    let viewId: String
    @Binding var viewRotation: Double
    
    @Environment(\.colorScheme) var colorScheme
    let realmInstance = realm()

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
        .background(getForegroundColor(colorScheme))
        .cornerRadius(8)
        .scaleEffect(1.0) // Enhanced scale effect
    }
    
    func loadFromRealm() {
        
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId)
        guard let umv = mv else { return }
        // set attributes
        viewRotation = umv.rotation
        let _ = colorFromRGBA(red: umv.colorRed, green: umv.colorGreen, blue: umv.colorBlue, alpha: umv.colorAlpha)
    }
}

struct MenuOptionSize: View {
    let label: String
    let imageName: String
    let viewId: String
    @Binding var viewSize: Double
    
    @Environment(\.colorScheme) var colorScheme
    let realmInstance = realm()

    var body: some View {
        Slider(
            value: $viewSize,
            in: 25...200,
            step: 1,
            onEditingChanged: { editing in
                if !editing {
                    let va = ViewAtts(viewId: viewId, size: viewSize)
                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                }
            }
        ).padding()
        .frame(maxWidth: 200, maxHeight: 50)
        .background(getForegroundColor(colorScheme))
        .cornerRadius(8)
        .scaleEffect(1.0) // Enhanced scale effect
        
    }
    
    
}

struct MenuOptionStroke: View {
    let label: String
    let imageName: String
    let viewId: String
    @Binding var lineStroke: Double
    
    
    @Environment(\.colorScheme) var colorScheme
    let realmInstance = realm()

    var body: some View {
        Slider(
            value: $lineStroke,
            in: 3...75,
            step: 1,
            onEditingChanged: { editing in
                if !editing {
                    let va = ViewAtts(viewId: viewId, stroke: lineStroke)
                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                }
            }
        ).padding()
        .frame(maxWidth: 200, maxHeight: 50)
        .background(getForegroundColor(colorScheme))
        .cornerRadius(8)
        .scaleEffect(1.0) // Enhanced scale effect
        
    }
    
    
}

struct MenuOptionColor: View {
    let label: String
    let imageName: String
    let viewId: String
    @Binding var viewColor: Color
    
    @Environment(\.colorScheme) var colorScheme
    let realmInstance = realm()

    var body: some View {
        ColorListPicker() { color in
            viewColor = color
            let va = ViewAtts(viewId: viewId, color: viewColor)
            CodiChannel.TOOL_ATTRIBUTES.send(value: va)
        }
        
        .frame(width: 200, height: 50)
        .background(getForegroundColor(colorScheme))
        .cornerRadius(8)
        .scaleEffect(1.0) // Enhanced scale effect
        .padding()
        
    }
    
    
}
