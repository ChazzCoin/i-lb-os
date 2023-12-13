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
   
    
    @State var cancellables = Set<AnyCancellable>()

    func animateOptionsIn() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) {
            self.PMO.showLockOption = true
        }
        withAnimation(.easeInOut(duration: 0.3).delay(0.25)) {
            self.PMO.showDeleteOption = true
        }
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) {
            self.PMO.showSizeOption = true
        }
    }
    
    func animateOptionsOut() {
        withAnimation(.easeInOut(duration: 0.3).delay(0.10)) {
            self.PMO.showLockOption = true
        }
        withAnimation(.easeInOut(duration: 0.3).delay(0.25)) {
            self.PMO.showDeleteOption = true
        }
        withAnimation(.easeInOut(duration: 0.3).delay(0.40)) {
            self.PMO.showSizeOption = true
        }
    }

    var body: some View {
        VStack(spacing: 1) {
            if self.PMO.showSizeOption {
                MenuOptionSlider(label: "Size", imageName: "arrow.up.left.and.arrow.down.right", viewId: self.PMO.viewId)
            }
            if self.PMO.showDeleteOption {
                MenuOptionButton(label: "Delete", imageName: "trash")
            }
            if self.PMO.showLockOption {
                MenuOptionButton(label: "Unlocked", imageName: "lock")
            }
        }
        .zIndex(5.0)
        .scaleEffect(6.0)
        .frame(width: 1000, height: 1000)
        .background(Color.clear)
        .cornerRadius(15)
        .shadow(radius: 10)
        .position(x: self.PMO.position.x, y: self.PMO.position.y - 500)
        .onAppear() {
            animateOptionsIn()
            self.BEO.gesturesAreLocked = true
            CodiChannel.TOOL_ON_FOLLOW.receive(on: RunLoop.main) { viewFollow in
                let vf = viewFollow as! ViewFollowing
                print("Monitoring View: X: \(vf.x) Y: \(vf.y) ")
                self.PMO.viewId = vf.viewId
                self.PMO.position = CGPoint(x: vf.x, y: vf.y)
            }.store(in: &cancellables)
        }
        .onDisappear() {
            self.BEO.gesturesAreLocked = false
        }
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
