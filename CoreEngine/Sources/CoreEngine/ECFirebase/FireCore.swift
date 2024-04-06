//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift


// Database Reference
public func firebaseDatabase(block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference()
    block(reference)
}

public extension DatabaseReference {
        
    func get(onSnapshot: @escaping (DataSnapshot) -> Void) {
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func delete(id: String) {
        self.child(id).removeValue()
    }
    
    func save(obj: Object) {
        self.setValue(obj.toDict())
    }
    
    func save(id: String, obj: Object) {
        self.child(id).setValue(obj.toDict())
    }
    
    func save(collection: String, id: String, obj: Object) {
        self.child(collection).child(id).setValue(obj.toDict())
    }
    
    func saveUser(obj: CoreUser) {
        self.child(DatabasePaths.users.rawValue)
            .child(obj.id)
            .setValue(obj.toDict())
    }
    
}

// Parser
public extension DataSnapshot {
    
    func toLudiObject<T: Object>(_ type: T.Type, realm: Realm = newRealm()) -> T? {
        let hashmap = self.toHashMap()
        return hashmap.toRealmObject(type, realm: realm)
    }

    // The Master List Of Firebase Objects Parser
    func toLudiObjects<T: Object>(_ type: T.Type, realm: Realm = newRealm()) -> List<T>? {
        let hashmap = self.toHashMap()
        let list = List<T>()
        for (_, value) in hashmap {
            if let tempHash = value as? [String: Any] {
                let temp: T? = tempHash.toRealmObject(type, realm: realm)
                if let itTemp = temp {
                    list.append(itTemp)
                }
            }
        }
        return list.isEmpty ? nil : list
    }
    
    func parseSingleObject(onComplete: ([String:Any?]) -> Void) {
        let temp = self.toHashMap()
        let tempp = temp.first?.value as? [String:Any?]
        if let tryme = tempp {
           onComplete(tryme)
        }
    }

    func toHashMap() -> [String: Any] {
        var hashMap = [String: Any]()
        
        if self.childrenCount < 2 {
            return self.value as? [String:Any] ?? hashMap
        }
        
        for child in children {
            let c = (child as? DataSnapshot)
            if let key = c?.key {
                hashMap[key] = c?.value
            }
        }
        return hashMap
    }
}


//

public enum DatabasePaths: String {
    case sports = "sports"
    case users = "users"
    case admin = "admin"
    case coaches = "coaches"
    case parents = "parents"
    case players = "players"
    case reviews = "reviews"
    case services = "services"
    case organizations = "organizations"
    case teams = "teams"
    case notes = "notes"
    case chat = "chat"
    case evaluations = "evaluations"
    case rosters = "rosters"
    case tryouts = "tryouts"
    case reviewTemplates = "review_templates"
    case redzones = "redzones"
    case events = "events"
    case sessionPlan = "sessionPlan"
    case activityPlan = "activityPlan"
    case boardSession = "boardSession"
    case managedViews = "managedViews"
    case stopWatch = "stopWatch"
    case timer = "timer"
    case userToSession = "userToSession"
    case userToActivity = "userToActivity"
    case connections = "connections"
    case rooms = "rooms"
    
    // Function to map object type to DatabasePaths
    public static func path(forObjectType objectType: Object.Type) -> DatabasePaths? {
        switch objectType {
            case is SessionPlan.Type:
                return .sessionPlan
            case is ActivityPlan.Type:
                return .activityPlan
            case is ManagedView.Type:
                return .managedViews
            case is UserToSession.Type:
                return .userToSession
            case is Chat.Type:
                return .chat
            case is UserToSession.Type:
                return .userToSession
            case is Room.Type:
                return .rooms
            default:
                return nil
        }
    }
    
}
