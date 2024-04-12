//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift



// Parser
public extension DataSnapshot {
    
    @available(*, deprecated, renamed: "toCoreObject", message: "Please stop using this.")
    func toLudiObject<T: Object>(_ type: T.Type, realm: Realm = newRealm()) -> T? {
        let hashmap = self.toHashMap()
        return hashmap.toRealmObject(type, realm: realm)
    }

    @available(*, deprecated, renamed: "toCoreObjects", message: "Please stop using this.")
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
    
    // Master
    func toCoreObject<T: Object>(_ type: T.Type, realm: Realm = newRealm()) -> T? {
        let hashmap = self.toHashMap()
        return hashmap.toCoreObject(type, realm: realm)
    }

    // Master
    func toCoreObjects<T: Object>(_ type: T.Type, realm: Realm = newRealm()) -> List<T>? {
        let hashmap = self.toHashMap()
        let list = List<T>()
        for (_, value) in hashmap {
            if let tempHash = value as? [String: Any] {
                let temp: T? = tempHash.toCoreObject(type, realm: realm)
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

    // Master
    func toHashMap() -> [String: Any] {
        var hashMap = [String: Any]()
        
        if self.childrenCount <= 1 {
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
    
    // Master
    func parseOutId() -> String? {
        let temp = self.toHashMap()
        if let tempId = temp["id"] as? String {
            return tempId
        }
        return nil
    }
    
    // Master
    func deleteRealmObject<T:Object>(ofType type: T.Type) {
        if let id = self.parseOutId() {
            newRealm().safeWrite { r in
                if let temp = r.findByField(type.self, value: id) {
                    print("Deleting Realm Object: \(temp)")
                    r.delete(temp)
                }
            }
        }
    }
    
    
}
