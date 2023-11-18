//
//  ManagedViewWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI

class ManagedViewWindow : ObservableObject {
    
    @Published var id: String
    @Published var content: ViewWrapper?
    @Published var boardId: String = ""
    @Published var title: String = ""
    
    @Published var isMinimized: Bool = false
    @Published var isFullScreen: Bool = true
    @Published var isGlobalWindow: Bool = false
    
    init(id: String) {
        self.id = id
    }

    func toggleMinimized() { isMinimized = !isMinimized }
    func toggleFullScreen() { isFullScreen = !isFullScreen }
}

class ManagedViewWindows {
    
    static let shared = ManagedViewWindows()
    
    @State var managedViewWindows: [ManagedViewWindow] = []
    
    func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
        return ManagedViewWindow(id: viewId)
    }
    
    func toggleManagedViewWindowById(viewId: String) {
        guard let temp = managedViewWindows.first(where: { $0.id == viewId }) else { return }
        temp.toggleMinimized()
    }
    
    func showHideManagedViewWindows() -> some View {
        ForEach(managedViewWindows, id: \.id) { window in
            if !window.isMinimized && !window.isFullScreen && !window.isGlobalWindow {
//                window.content?.view()
            }
        }
    }

    func globalManagedViewWindows() -> some View {
        ForEach(managedViewWindows, id: \.id) { window in
            if window.isGlobalWindow && !window.isMinimized {
                ManagedViewWindowView(managedViewWindow: window)
            }
        }
    }

}

struct ManagedViewWindowView: View {
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State var managedViewWindow: ManagedViewWindow
    
    // Accessing screen dimensions
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Your content here
//                managedViewWindow.content?.view()
            }
            .frame(width: managedViewWindow.isFullScreen ? screenWidth : 300,
                   height: managedViewWindow.isFullScreen ? screenHeight : 300)
            .background(Color.red)
            .overlay(
                Rectangle() // The rectangle that acts as the border
                    .stroke(Color.red, lineWidth: 2) // Red border with a stroke width of 2
                    .frame(width: managedViewWindow.isFullScreen ? screenWidth : 300, height: managedViewWindow.isFullScreen ? screenHeight : 300)
                    .position(x: 0.0, y: 0.0)
                )
            .cornerRadius(10)
            .shadow(radius: 8)
            .rotationEffect(Angle(degrees: getRotation()))
            .offset(x: offset.width, y: offset.height)

            .onAppear {
                rotation = getRotation()
            }
        }
        .zIndex(5)
    }

    private func getRotation() -> Double {
        // Implement the logic to determine the rotation
        return 0.0
    }
}


struct GenericWindow<Content: View>: View {
    let content: Content
    
    @State private var managedViewWindow: ManagedViewWindow? = nil
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    

    init(@ViewBuilder content: () -> Content) {
//        self.managedViewWindow = managedViewWindow
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Taskbar
            taskbarView
                .padding()

            // Content
            content
        }
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

    var taskbarView: some View {
        HStack {
            Text("Window Title")
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            // Add buttons or icons here for minimize, maximize, close, etc.
        }
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

struct GenericWindowPreview: PreviewProvider {
    static var previews: some View {
        GenericWindow {
            // Your custom view here
            Text("Content goes here")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 300, height: 200)
    }
}

// Example usage
struct ContentView2: View {
    var body: some View {
        GenericWindow {
            // Your custom view here
            Text("Content goes here")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 300, height: 200)
    }
}
