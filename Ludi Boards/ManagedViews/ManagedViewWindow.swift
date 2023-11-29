//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import Combine

class ManagedViewWindow {
    
    @Published var id: String
    @Published var content: AnyView?
    @Published var boardId: String = ""
    @Published var title: String = "Ludi Window"
    @Published var windowId: String = "Ludi Window"
    
    @Published var isMinimized: Bool = false
    @Published var isFullScreen: Bool = true
    @Published var isGlobalWindow: Bool = false
    
    init(id: String, content: AnyView) {
        self.id = id
        self.content = content
    }

    func setContent<Content: View>(_ newContent: Content) {
        self.content = AnyView(newContent)
    }

    func toggleMinimized() { isMinimized = !isMinimized }
    func toggleFullScreen() { isFullScreen = !isFullScreen }
}

class ManagedViewWindows:ObservableObject {
    
    static let shared = ManagedViewWindows()
    
    @Published var managedViewWindows: [ManagedViewWindow] = []
    @Published var managedViewGenerics: [String:ViewWrapper] = [:]
    
    func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
        return ManagedViewWindow(id: viewId, content: AnyView(ChatView(chatId: "default-1")))
    }
    
    func toggleManagedViewWindowById(viewId: String) {
        guard let temp = managedViewWindows.first(where: { $0.id == viewId }) else { return }
        temp.toggleMinimized()
    }
    
    func toggleItem(key: String, item: ViewWrapper) {
        DispatchQueue.main.async {
            if self.managedViewGenerics[key] != nil {
                self.managedViewGenerics.removeValue(forKey: key)
            } else {
                self.managedViewGenerics[key] = item
            }
        }
    }
    
    func safelyAddItem(key: String, item: ViewWrapper) {
        DispatchQueue.main.async {
            self.managedViewGenerics[key] = item
        }
    }
    func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.managedViewGenerics.removeValue(forKey: key)
        }
    }

}

struct NavStackWindow : View {
    
    @State var managedViewWindow: ManagedViewWindow
    
    @State private var isHidden = true
    @State private var isFloatable = false
    
    @State var cancellables = Set<AnyCancellable>()
    @State var screen: UIScreen = UIScreen.main
        
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    @State private var width = 0.0
    @State private var height = 0.0
    
    func getPositionX() -> Double {return isHidden ? screen.bounds.width : (((screen.bounds.width + 75.0)/2) / 2)}
    func getFloatableWidth() -> Double { return (screen.bounds.width/2) }
    func getFloatableHeight() -> Double { return (screen.bounds.height/2) }
    func resetSize() {
        self.width = (!isFloatable ? ((screen.bounds.width - 100.0)/2) : getFloatableWidth()).bound(to: 100...screen.bounds.width - 100.0)
        self.height = (!isFloatable ? screen.bounds.height : getFloatableHeight()).bound(to: 100...screen.bounds.height)
        
    }
    func resetPosition() {
        offset = CGSize.zero
        position = CGPoint(x: 0, y: 0)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let windowContent = managedViewWindow.content {
                    windowContent
                } else {
                    // Placeholder or fallback view
                    Text("No content available")
                }
            }.opacity(isHidden ? 0 : 1)
            .navigationBarItems(trailing: HStack {
                
                if self.isFloatable {
                    Button(action: {
                        // Minimize:
                        self.width = (self.width + 50).bound(to: 400...screen.bounds.width)
                        self.height = (self.height + 50).bound(to: 400...screen.bounds.height)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        // Minimize:
                        self.width = (self.width - 50).bound(to: 400...screen.bounds.width)
                        self.height = (self.height - 50).bound(to: 400...screen.bounds.height)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                
                
                Button(action: {
                    self.isFloatable = !self.isFloatable
                    resetSize()
                    resetPosition()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                Button(action: {
                    self.isHidden = true
                    self.isFloatable = false
                    resetSize()
                    resetPosition()
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
               
            })
        }
        .frame(width: self.width, height: self.height)
        .opacity(isHidden ? 0 : 1)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .offset(x: position.x + (isDragging ? dragOffset.width : 0) + (!isFloatable ? getPositionX() : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .animation(.easeInOut(duration: 1.0), value: isHidden)
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    if !self.isFloatable {return}
                    state = value.translation
                })
                .onChanged { _ in
                    if !self.isFloatable {return}
                    self.isDragging = true
                }
                .onEnded { value in
                    if !self.isFloatable {return}
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        )
        .onAppear() {
            
            resetSize()
            
            CodiChannel.MENU_WINDOW_TOGGLER.receive(on: RunLoop.main) { windowType in
                print(windowType)
                if (windowType as! String) != self.managedViewWindow.windowId { return }
                if self.isHidden {
                    self.isHidden = false
                } else {
                    self.isHidden = true
                    self.isFloatable = false
                    resetSize()
                    resetPosition()
                }
            }.store(in: &cancellables)
            
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                print(wc)
                let temp = wc as! WindowController
                if temp.windowId != self.managedViewWindow.windowId { return }

                if temp.stateAction == "open" {
                    if self.isHidden { self.isHidden = false }
                } else {
                    if !self.isHidden {
                        self.isHidden = true
                        self.isFloatable = false
                        resetSize()
                        resetPosition()
                    }
                }
            }.store(in: &cancellables)
        }
    }

}


struct GenericNavWindowSMALL : View {
    
    @State var managedViewWindow: ManagedViewWindow
    
    @State private var isHidden = false
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let windowContent = managedViewWindow.content {
                    windowContent
                } else {
                    // Placeholder or fallback view
                    Text("No content available")
                }
            }.opacity(isHidden ? 0 : 1)
            .navigationBarItems(trailing: HStack {
                // Add buttons or icons here for minimize, maximize, close, etc.
                Button(action: {
                    // Minimize:
                    CodiChannel.general.send(value: managedViewWindow.windowId)
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            })
        }
        .frame(minWidth: 100, maxWidth: 400, minHeight: 100, maxHeight: 400)
        .opacity(isHidden ? 0 : 1)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
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
        )
    }

}
