//
//  RealmInstance.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/24/23.
//

import Foundation
import RealmSwift

class RealmInstance {
    static let instance: Realm = {
        return try! Realm()
    }()
}

func realm() -> Realm {
    return RealmInstance.instance
}

func isRealmObjectValid(_ object: Object) -> Bool {
    return !object.isInvalidated
}

extension Object {
    func isRealmObjectValid() -> Bool {
        return !self.isInvalidated
    }
}

func safeAccess<T>(to object: T, action: (T) -> Void) where T: Object {
    guard !object.isInvalidated else {
        print("Object is invalidated.")
        return
    }
    action(object)
}

extension Realm {
    
    // Using a closure as a shortcut for realm().write
    func safeWrite(_ block: @escaping (Realm) -> Void) {
        if isInWriteTransaction {
            DispatchQueue.main.async {
                try? write {
                    block(self)
                }
            }
        } else {
            try? write {
                block(self)
            }
        }
    }
    
    
}

extension Object {
    
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        let properties = self.objectSchema.properties.map { $0.name }
        
        for property in properties {
            if let value = dictionary[property] {
                self.setValue(value, forKey: property)
            }
        }
    }
    
    func toDict() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }
    
    
//    func updateFieldsAndSave(newObject: Object, realm: Realm) {
//        do {
//            try realm.write {
//                let fields = Mirror(reflecting: self).children.compactMap { $0.label }
//                for field in fields {
//                    if field != "id" {
//                        let newValue = newObject.value(forKey: field)
//                        self.setValue(newValue, forKey: field)
//                    }
//                }
//                realm.add(self, update: .modified)
//            }
//        } catch {
//            print("Error updating fields and saving object: \(error)")
//        }
//    }
}


