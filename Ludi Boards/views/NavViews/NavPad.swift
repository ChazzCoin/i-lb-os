//
//  NavPad.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/5/23.
//

import Foundation
import SwiftUI
import Combine
import CoreEngine

struct NavPadView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @Environment(\.colorScheme) var colorScheme
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    @State private var isHidden = true
    
    @State var cancellables = Set<AnyCancellable>()
    var body: some View {
        HStack(spacing: 15) {
            NavButton(label: "arrow.up", action: { self.BEO.navUp() })
            NavButton(label: "arrow.down", action: { self.BEO.navDown() })
            NavButton(label: "arrow.left", action: { self.BEO.navLeft() })
            NavButton(label: "arrow.right", action: { self.BEO.navRight() })
            NavButton(label: "plus.magnifyingglass", action: { self.BEO.canvasScale += 0.02 })
            NavButton(label: "minus.magnifyingglass", action: { self.BEO.canvasScale -= 0.02 })
            NavButton(label: "rotate.left", action: { self.BEO.canvasRotation += -45.0 })
            NavButton(label: "rotate.right", action: { self.BEO.canvasRotation += 45.0 })
            NavButton(label: "house", action: { self.BEO.fullScreen() })
        }
        .frame(width: 55 * 8, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(getBackgroundColor(colorScheme))
                .shadow(radius: 5)
        )
        .opacity(isHidden ? 0 : 1)
        .offset(x: position.x + (isDragging ? dragOffset.width : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .gesture(
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
        ).onAppear() {
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                print(wc)
                let temp = wc as! WindowController
                if temp.windowId != MenuBarProvider.navHome.tool.title { return }
                
                if temp.stateAction == "toggle" {
                    self.isHidden = !self.isHidden
                } else if temp.stateAction == "open" {
                    self.isHidden = false
                } else if temp.stateAction == "close" {
                    self.isHidden = true
                }
            }.store(in: &cancellables)
        }
    }
}

struct NavButton2: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 40, height: 40) // Circle size
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

struct NavButton: View {
    @State var label: String
    @State var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isLocked = false
    @State private var lifeColor = Color.black
    @State private var lifeWindowState = true
    
    func setColorScheme() { lifeColor = getForegroundColor(colorScheme) }

    var body: some View {
        Image(systemName: label)
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(lifeColor)
            .onTapAnimation {
                action()
            }.onAppear() {
                setColorScheme()
            }
    }
}
