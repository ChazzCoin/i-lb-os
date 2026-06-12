//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/7/24.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase


public struct Node: Identifiable {
    public let id: UUID
    public var position: CGPoint
    public var size: CGSize
    public var zIndex: Double
    public let view: AnyView
}

public func clamp(position: CGPoint, to bounds: CGRect) -> CGPoint {
    CGPoint(x: min(max(position.x, bounds.minX), bounds.maxX), y: min(max(position.y, bounds.minY), bounds.maxY))
}

// Parent (Type)
public class ManagedViewEngine: ObservableObject {

    // The UserDefaults key this engine filters tools by. Rooms-based apps
    // (Wrlds) keep the default; Ludi Boards passes "currentActivityId" so
    // the render filter matches the key its creation paths write.
    public let boardIdKey: String

    public init(idKey: String = "currentRoomId") {
        self.boardIdKey = idKey
        self._roomId = AppStorage(wrappedValue: "", idKey)
    }

    public init(idKey: String = "currentRoomId", bounds: CGRect) {
        self.boardIdKey = idKey
        self._roomId = AppStorage(wrappedValue: "", idKey)
        self.bounds = bounds
    }

    @State var bounds: CGRect = CGRect(origin: .zero, size: CGSize(width: 20000.0, height: 20000.0))
    @Published public var nodes: [UUID : Node] = [:]

    public func updateBounds(bounds: CGRect) {
        self.bounds = bounds
    }

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage var roomId: String

    @ObservedResults(ManagedView.self) public var allTools
    public var boardManagedViews: Results<ManagedView> {
        // Strict filter: tools created with an empty board id ("" — the
        // default local board) match an empty filter value, so the free,
        // no-activity flow still renders. No id ever shows another board's tools.
        return allTools.filter("boardId == %@", roomId)
    }

    @ViewBuilder
    public func Display(reset: Binding<Bool> = .constant(false)) -> some View {
        if !reset.wrappedValue {
            ForEach(boardManagedViews) { item in
                if !item.isDeleted {
                    ViewEngine.GenreBuilder(for: item.sport, in: item.toolType, as: item.subToolType, viewId: item.id, activityId: item.boardId, bounds: self.bounds)
                }
            }
        }
    }
    @ViewBuilder
    public func Nodes(reset: Binding<Bool> = .constant(false)) -> some View {
        if !reset.wrappedValue {
            ForEach(Array(self.nodes.values)) { node in
                WindowManagerView {
                    node.view
                }
                
//                .frame(width: node.size.width, height: node.size.height)
//                .position(node.position)
//                .zIndex(node.zIndex)
//                .environmentObject(self)
//                .scaleEffect(7.0)
            }
        }
    }
    
    // Firebase
    @Published public var reference: DatabaseReference = Database.database().reference()
    @Published public var observeFireChildAdded: DatabaseHandle?
    @Published public var observeFireChildRemoved: DatabaseHandle?
    
    public static func createNewTool(viewId: String = UUID().uuidString, activityId: String, toolType: String, subToolType: String, sport: String, x: Double = 0.0, y: Double = 0.0) {
        
        FusedTools.fusedCreator(ManagedView.self) { r in
            let newTool = ManagedView()
            newTool.id = viewId
            newTool.toolType = toolType
            newTool.subToolType = subToolType
            newTool.sport = sport
            newTool.boardId = activityId
            newTool.x = x
            newTool.y = y
            return newTool
        }
        
    }
    
    // Observers
    public func restartManagedViewObservers() {
        if roomId.isEmpty { return }
        observeFireChildAdded = nil
        observeFireChildRemoved = nil
        observeManagedViewsInFirebase()
    }
    
    public func startManagedViewObservers() {
        if roomId.isEmpty { return }
        observeManagedViewsInFirebase()
    }
    
    // Firebase
    public func observeManagedViewsInFirebase() {
        if !isLoggedIn {
            print("User is not logged in.")
            return
        }
        if roomId.isEmpty { return }
        observeFireChildAdded = reference
            .child(DatabasePaths.managedViews.rawValue)
            .queryOrdered(byChild: "boardId").queryEqual(toValue: roomId)
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObjects(ManagedView.self, realm: self.allTools.realm?.thaw() ?? newRealm())
            })
        
        observeFireChildRemoved = reference
            .child(DatabasePaths.managedViews.rawValue)
            .queryOrdered(byChild: "boardId").queryEqual(toValue: roomId)
            .observe(.childRemoved, with: { snapshot in
                snapshot.deleteRealmObject(ofType: ManagedView.self)
            })
    }
    
    //
    
    public func addNode(
        id: UUID = UUID(),
        position: CGPoint,
        size: CGSize,
        zIndex: Double = 0,
        @ViewBuilder view: () -> some View
    ) {
        nodes[id] = Node(
            id: id,
            position: position,
            size: size,
            zIndex: zIndex,
            view: AnyView(view())
        )
    }
    public func updatePosition(id: UUID, _ newPosition: CGPoint) {
        guard var node = nodes[id] else { return }
        node.position = clamp(node: node, to: bounds)
        nodes[id] = node
    }
    public func clamp(position: CGPoint, to bounds: CGRect) -> CGPoint {
        CGPoint(x: min(max(position.x, bounds.minX / 2), bounds.maxX / 2), y: min(max(position.y, bounds.minY / 2), bounds.maxY / 2))
    }
    private func clamp(node: Node, to bounds: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(node.position.x, bounds.minX + node.size.width / 2),
                   bounds.maxX - node.size.width / 2),
            y: min(max(node.position.y, bounds.minY + node.size.height / 2),
                   bounds.maxY - node.size.height / 2)
        )
    }

}




