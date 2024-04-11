//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI
import Combine


public struct NavStackFloatingWindow : View {
    @State public var id: String
    public var viewBuilder: () -> AnyView
    
    
    public init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }
    @State public var screenWidth = UIScreen.main.bounds.width
    @State public var screenHeight = UIScreen.main.bounds.height
    
    @State public var width = 500.0
    @State public var height = 500.0
    @State public var scale = 7.0

    @State public var cancellables = Set<AnyCancellable>()
    @State public var isHidden = false
    
    @State public var isLocked = false
    @State public var unLockedImage = "lock.open.fill"
    @State public var lockedImage = "lock.fill"
    
    @State public var offset = CGSize.zero
    @State public var position = CGPoint(x: 0, y: 0)
    @GestureState public var dragOffset = CGSize.zero
    @State public var isDragging = false
    
    public func resetSize() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.width = min(screenWidth, screenHeight) * 0.65
        } else {
            self.width = min(screenWidth, screenHeight) * 0.8
        }
        
        self.height = min(screenWidth, screenHeight) * 0.85
    }

    public var body: some View {
        Form {
            viewBuilder()
        }
//        .frame(width: self.width, height: self.height)
//        .scaleEffect(scale)
        .background(Color.green)
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
//            resetSize()
        }
    }

}

