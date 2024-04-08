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
public class ManagedViewFactory: ObservableObject {
    public static let basic: String = "basic"
    public static let shape: String = "shape"
    
    public var type: String = ""
    public var subType: String = ""
    public var sport: String = ""
    public init(type: String = "", subType: String = "", sport: String = "") {
        self.type = type
        self.subType = subType
        self.sport = sport
    }
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Published public var basicTools: [ManagedView] = []    // Realm
    public let realmInstance: Realm = newRealm()
    @Published public var managedViewNotificationToken: NotificationToken? = nil
    // Firebase
    @Published public var reference: DatabaseReference = Database.database().reference()
    @Published public var observeFireChildAdded: DatabaseHandle?
    @Published public var observeFireChildRemoved: DatabaseHandle?
    
    public static func build(type: String, subType: String, sport: String) -> ManagedViewFactory {
        return ManagedViewFactory(type: type, subType: subType, sport: sport)
    }
    
    public static func getSubType(type: String, subType: String, sport: String) -> ManagedToolProvider {
        switch type {
            case basic: return BasicToolProvider(subType: subType, sport: sport)
            case shape: return ShapeToolProvider(subType: subType, sport: sport)
            default: return BasicToolProvider(subType: subType, sport: sport)
        }
    }
    
    public func getView(viewId: String, activityId: String) -> AnyView {
        switch type {
            case ManagedViewFactory.basic: return BasicToolProvider(subType: subType, sport: sport).view(viewId: viewId, activityId: activityId)
            case ManagedViewFactory.shape: return ShapeToolProvider(subType: subType, sport: sport).view(viewId: viewId, activityId: activityId)
            default: return BasicToolProvider(subType: subType, sport: sport).view(viewId: viewId, activityId: activityId)
        }
    }
    
    public func createNewTool(activityId: String, x: Double = 0.0, y: Double = 0.0) {
        let newTool = ManagedView()
        newTool.toolType = type
        newTool.subToolType = subType
        newTool.sport = sport
        newTool.boardId = activityId
        newTool.x = x
        newTool.y = y
        realmInstance.safeWrite { r in
            r.create(ManagedView.self, value: newTool, update: .all)
            r.refresh()
        }
        // Firebase
        // newTool.fireSave(parentId: activityId, id: newTool.id)
//        return newTool.id
    }
    
    // Observers
    public func restartManagedViewObservers(activityId: String) {
        if activityId.isEmpty { return }
        self.basicTools.removeAll()
        observeFireChildAdded = nil
        observeFireChildRemoved = nil
        managedViewNotificationToken?.invalidate()
        managedViewNotificationToken = nil
        observeManagedViewsInRealm(activityId: activityId)
        observeManagedViewsInFirebase(activityId: activityId)
    }
    
    public func startManagedViewObservers(activityId: String) {
        if activityId.isEmpty { return }
        self.basicTools.removeAll()
        observeManagedViewsInRealm(activityId: activityId)
        observeManagedViewsInFirebase(activityId: activityId)
    }
    
    // Realm
    public func observeManagedViewsInRealm(activityId: String) {
        if activityId.isEmpty { return }
        // Realm
        if let umvs = self.realmInstance.findAllByField(ManagedView.self, field: "boardId", value: activityId) {
            // Start Up Observer
            self.realmInstance.executeWithRetry {
                self.managedViewNotificationToken = umvs.observe { (changes: RealmCollectionChange) in
                    DispatchQueue.main.async {
                        switch changes {
                            case .initial(let results):
                                print("Realm Listener: initial")
                                for i in results {
                                    if i.isInvalidated {continue}
                                    self.basicTools.safeAddManagedView(i)
                                }
                            case .update(let results, let de, _, _):
                                print("Realm Listener: update")
                                
                                for d in de {
                                    self.basicTools.remove(at: d)
                                }
                                
                                for i in results {
                                    if i.isInvalidated {continue}
                                    self.basicTools.safeAddManagedView(i)
                                }
                            case .error(let error):
                                print("Realm Listener: \(error)")
                                self.managedViewNotificationToken?.invalidate()
                                self.managedViewNotificationToken = nil
                        }
                    }
                }
            }
        }
    }
    
    // Firebase
    public func observeManagedViewsInFirebase(activityId: String) {
        if !isLoggedIn {
            print("User is not logged in.")
            return
        }
        observeFireChildAdded = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(activityId)
            .observe(.childAdded, with: { snapshot in
                if let temp = snapshot.value as? [String:Any] {
                    let mv = ManagedView(dictionary: temp)
                    if self.basicTools.hasView(mv) {
                        return
                    }
                    self.realmInstance.safeWrite { r in
                        r.create(ManagedView.self, value: mv, update: .all)
                    }
//                    createHistoricalSnapShotAtStart(tool: mv)
                    self.basicTools.safeAddManagedView(mv)
                }
            })
        
        observeFireChildRemoved = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(activityId)
            .observe(.childRemoved, with: { snapshot in
                let temp = snapshot.toHashMap()
                if let tempId = temp["id"] as? String {
                    self.basicTools.safeRemoveById(tempId)
                }
            })
    }

}




