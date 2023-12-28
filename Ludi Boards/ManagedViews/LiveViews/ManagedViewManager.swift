//
//  mvListener.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/6/23.
//

import Foundation
import RealmSwift
import Combine

class ManagedViewListener : ObservableObject {
    
    @Published var activityID: String = ""
    @Published var realmInstance: Realm = realm()
    
    @Published var basicTools: [ManagedView] = []
    @Published private var cancellables = Set<AnyCancellable>()
    @Published private var managedViewNotificationToken: NotificationToken? = nil
    
    func loadTools(activityId:String) {
        self.activityID = activityId
        self.basicTools.removeAll()
        if let umvs = realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.activityID) {
            if !umvs.isEmpty {
                for i in umvs {
                    if i.isInvalidated {continue}
                    self.basicTools.safeAdd(i)
                }
            }
        }
    }
    
    func disable() {
        managedViewNotificationToken?.invalidate()
        self.basicTools.removeAll()
    }
    
    func enable(activityId:String) {
        self.activityID = activityId
        self.basicTools.removeAll()
        
        // TODO: Firebase Users ONLY
        fireManagedViewsAsync(activityId: self.activityID, realm: self.realmInstance)
        
        // FREE
        let umvs = realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.activityID)
        managedViewNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
            switch changes {
                case .initial(let results):
                    print("Realm Listener: initial")
                    for i in results {
                        if i.isInvalidated {continue}
                        self.basicTools.safeAdd(i)
                    }
                case .update(let results, let de, _, _):
                    print("Realm Listener: update")
                    
                    for d in de {
                        self.basicTools.remove(at: d)
                    }
                    
                    for i in results {
                        if i.isInvalidated {continue}
                        self.basicTools.safeAdd(i)
                    }
                case .error(let error):
                    print("Realm Listener: error")
                    fatalError("\(error)")  // Handle errors appropriately in production code
            }
        }
        
    }
}
