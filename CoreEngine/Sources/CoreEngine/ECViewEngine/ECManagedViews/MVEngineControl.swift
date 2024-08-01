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




// Parent (Type)
public class ManagedViewEngine: ObservableObject {
    
    public init() {}
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentActivityId") var boardId: String = ""
    
    @ObservedResults(ManagedView.self) public var allTools
    public var boardManagedViews: Results<ManagedView> {
        if boardId.isEmpty { return allTools }
        return allTools.filter("boardId == %@", boardId)
    }

    @ViewBuilder
    public func Display(reset: Binding<Bool> = .constant(false)) -> some View {
        if !reset.wrappedValue {
            ForEach(boardManagedViews) { item in
                if !item.isDeleted {
                    ViewEngine.GenreBuilder(for: item.sport, in: item.toolType, as: item.subToolType, viewId: item.id, activityId: item.boardId)
                }
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
        if boardId.isEmpty { return }
        observeFireChildAdded = nil
        observeFireChildRemoved = nil
        observeManagedViewsInFirebase()
    }
    
    public func startManagedViewObservers() {
        if boardId.isEmpty { return }
        observeManagedViewsInFirebase()
    }
    
    // Firebase
    public func observeManagedViewsInFirebase() {
        if !isLoggedIn {
            print("User is not logged in.")
            return
        }
        if boardId.isEmpty { return }
        observeFireChildAdded = reference
            .child(DatabasePaths.managedViews.rawValue)
            .queryOrdered(byChild: "boardId").queryEqual(toValue: boardId)
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObjects(ManagedView.self, realm: self.allTools.realm?.thaw() ?? newRealm())
            })
        
        observeFireChildRemoved = reference
            .child(DatabasePaths.managedViews.rawValue)
            .queryOrdered(byChild: "boardId").queryEqual(toValue: boardId)
            .observe(.childRemoved, with: { snapshot in
                snapshot.deleteRealmObject(ofType: ManagedView.self)
            })
    }

}




