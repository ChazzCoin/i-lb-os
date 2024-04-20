//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift


public struct enableDynaNavStackModifier : ViewModifier {
    
    @State public var viewId: String
    @State public var activityId: String
    
    public init(viewId: String, activityId: String="") {
        self.viewId = viewId
        self.activityId = activityId
    }
    @State public var navSize = NavStackSize.full
    @State public var useOriginal = false
    @State public var offset = CGSize.zero
    @State public var offPos = CGPoint.zero
    @State public var originOffPos = CGPoint(x: 0, y: 0)
    @State public var position = CGPoint.zero
    @State public var originalPosition = CGPoint(x: 0, y: 0)
    
    @State public var isLocked = false
    @State public var isFloatable = false
    @State public var isDisabled = false
    @State public var isDragging = false
    
    @GestureState public var dragOffset = CGSize.zero
    
    public var realmInstance: Realm = newRealm()
    public var cancellables = Set<AnyCancellable>()
    
    @State public var width: Double = 0.0
    @State public var height: Double = 0.0

    public func body(content: Content) -> some View {
        GeometryReader { pGeo in
            content
                .frame(width: width, height: height)
//                .measure { g in
//                    main {
//                        self.width = g.size.width
//                        self.height = g.size.height
//                    }
//                }
                .offset(
                    x: offPos.x + (isDragging ? dragOffset.width : 0),
                    y: (offPos.y + (isDragging ? dragOffset.height : 0))
                )
                .simultaneousGesture(!isLocked && isFloatable ? gestureDragBasicTool() : nil)
                .onAppear {
                    print("OnAppear: BasicTool.")
                    self.loadDynaView()
                }
        }
        
    }
    
    public func gestureDragBasicTool() -> some Gesture {
        DragGesture()
            .onChanged { value in
                main {
                    self.isDragging = true
                    if useOriginal {
                        originOffPos = offPos
                        useOriginal = false
                    }
                    offPos = CGPoint(
                        x: originOffPos.x + value.translation.width,
                        y: originOffPos.y + value.translation.height
                    )
                    saveDynaView()
                }
            }
            .onEnded { value in
                main {
                    offPos = CGPoint(
                        x: originOffPos.x + value.translation.width,
                        y: originOffPos.y + value.translation.height
                    )
                    isDragging = false
                    useOriginal = true
                    saveDynaView()
                }
            }
    }
    
    public func loadDynaView() {
        if let managedView = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
            mainAnimation {
                if managedView.toolType == NavStackSize.full.rawValue {
                    self.navSize = NavStackSize.full
                    self.width = NavStackSize.full.width
                    self.height = NavStackSize.full.height
                } else if managedView.toolType == NavStackSize.full_menu_bar.rawValue {
                    self.navSize = NavStackSize.full_menu_bar
                    self.width = NavStackSize.full_menu_bar.width
                    self.height = NavStackSize.full_menu_bar.height
                } else if managedView.toolType == NavStackSize.floatable_medium.rawValue {
                    self.navSize = NavStackSize.floatable_medium
                    self.width = NavStackSize.floatable_medium.width
                    self.height = NavStackSize.floatable_medium.height
                }
                if managedView.isLocked {
                    self.isFloatable = true
                    self.navSize = NavStackSize.floatable_medium
                    self.width = NavStackSize.floatable_medium.width
                    self.height = NavStackSize.floatable_medium.height
                }
                self.position = CGPoint(x: managedView.startX, y: managedView.startY)
                self.offPos = CGPoint(x: managedView.x, y: managedView.y)
            }
        }
    }
    
    public func saveDynaView() {
        guard let managedView = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) else {
            realmWriter { r in
                let managedView = ManagedView()
                managedView.id = self.viewId
                managedView.toolType = self.navSize.rawValue
                managedView.isLocked = self.isFloatable
                managedView.x = self.offPos.x
                managedView.y = self.offPos.y
                r.create(ManagedView.self, value: managedView, update: .all)
                r.refresh()
            }
            return
        }
        realmWriter { r in
            managedView.toolType = self.navSize.rawValue
            managedView.isLocked = self.isFloatable
            managedView.width = Int(self.width)
            managedView.height = Int(self.height)
            managedView.x = self.offPos.x
            managedView.y = self.offPos.y
            managedView.startX = self.position.x
            managedView.startY = self.position.y
        }
    }
    
}
