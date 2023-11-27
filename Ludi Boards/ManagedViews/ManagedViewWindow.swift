//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI

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

struct GenericWindow : View {
    
    @State var managedViewWindow: ManagedViewWindow
    
    @State private var isHidden = false
    
    @State var screen: UIScreen = UIScreen()
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    var body: some View {
        VStack(spacing: 0) {
            // Taskbar
            taskbarView
                .padding()
            if let windowContent = managedViewWindow.content {
                windowContent
            } else {
                // Placeholder or fallback view
                Text("No content available")
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .opacity(isHidden ? 0:1)
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
        .frame(minWidth: 100, maxWidth: 400, minHeight: 100, maxHeight: 300)
    }

    var taskbarView: some View {
        HStack {
            Text(managedViewWindow.title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            // Add buttons or icons here for minimize, maximize, close, etc.
            Button(action: {
                
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }.frame(height: 50)
            Button(action: {
                // Minimize:
                isHidden = true
                CodiChannel.general.send(value: managedViewWindow.windowId)
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }.frame(height: 50)
        }
    }
}


struct GenericNavWindow : View {
    
    @State var managedViewWindow: ManagedViewWindow
    
    @State private var isHidden = false
    
    @State var screen: UIScreen = UIScreen.main
    
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
        .frame(minWidth: 100, maxWidth: screen.bounds.width/2, minHeight: 100, maxHeight: screen.bounds.height/1.25)
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
        .frame(minWidth: 100, maxWidth: 300, minHeight: 100, maxHeight: 300)
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
