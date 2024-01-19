//
//  FireParser.swift
//
//  Created by Charles Romeo on 11/13/23.
//  Copyright © 2023 Ludi Software. All rights reserved.
//

import Foundation
import FirebaseDatabase
import RealmSwift

 //1. Master Parsing Function Part 1 - From Firebase Object to Realm Object
extension DataSnapshot {
    func toLudiObject<T: Object>(_ type: T.Type, realm: Realm? = nil) -> T? {
        let hashmap = self.toHashMap()
        return hashmap.toRealmObject(type, realmParameter: realm)
    }

    // The Master List Of Firebase Objects Parser
    func toLudiObjects<T: Object>(_ type: T.Type, realm: Realm? = nil) -> List<T>? {
        let hashmap = self.toHashMap()
        let list = List<T>()
        for (_, value) in hashmap {
            if let tempHash = value as? [String: Any] {
                let temp: T? = tempHash.toRealmObject(type, realmParameter: realm)
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

    // Master toHashMap Helper Function
    func toHashMap1() -> [String: Any] {
        var hashMap = [String: Any]()
        print("!! Snapshot: \(self)")
        print("!! Snapshot Child Count: \(self.childrenCount)")
        print("!! Snapshot Has Child: \(self.hasChildren())")
        for child in children {
            let c = (child as? DataSnapshot)
            if let key = c?.key {
                hashMap[key] = c?.value
            }
        }
        return hashMap
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

// Master Universal Realm Parser

extension Dictionary where Key == String, Value == Any {
    func toRealmObject<T: Object>(_ type: T.Type, realmParameter: Realm? = nil) -> T? {
        if let realm = realmParameter {
            var object: T?
            realm.safeWrite { _ in
                object = realm.create(type, value: self, update: .all)
                realm.refresh()
//                CodiChannel.REALM_ON_CHANGE.send(value: self["id"] ?? "nil")
            }
            return object
        } else {
            let realm = realm()
            var object: T?
            realm.safeWrite { _ in
                object = realm.create(type, value: self, update: .all)
                realm.refresh()
//                CodiChannel.REALM_ON_CHANGE.send(value: self["id"] ?? "nil")
            }
            return object
        }
        }
}

