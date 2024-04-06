//
//  RealmInstance.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/24/23.
//

import Foundation
import RealmSwift

/*
    DO NOT MODIFY THIS FUCKING FILE.
 
        PERIOD.
 
            DO NOT TOUCH IT.
 
                GO AWAY.
 */

public class RealmInstance {
    static let instance: Realm = { return try! Realm() }()
}
public func realm() -> Realm { return RealmInstance.instance }
public func newRealm() -> Realm { return RealmInstance.instance }
public func isRealmObjectValid(_ object: Object) -> Bool { return !object.isInvalidated }

public func safeAccess<T>(to object: T, action: (T) -> Void) where T: Object {
    guard !object.isInvalidated else {
        print("Object is invalidated.")
        return
    }
    action(object)
}



public extension Realm {
    func findByField<T: Object>(_ type: T.Type, field: String = "id", value: String?) -> T? {
        guard let value = value else { return nil }
        return objects(type).filter("\(field) == %@", value).first
    }
    
    func safeFindByField<T: Object>(_ type: T.Type, field: String = "id", value: String?, onSafe: (T) -> Void) {
        guard let value = value else { return }
        if let obj = objects(type).filter("\(field) == %@", value).first {
            onSafe(obj)
        }
    }
    
    func findAllByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K == %@", field, value)
    }
    
    func findAllNotByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K != %@", field, value)
    }
}

public extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}

public extension Realm {
    
    func executeWithRetry(maxRetries: Int = 3, operation: @escaping () -> Void) {
        func attempt(_ currentRetry: Int) {
            if isInWriteTransaction {
                if currentRetry < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        attempt(currentRetry + 1)
                    }
                } else {
                    print("Failed to execute operation after \(maxRetries) retries.")
                }
            } else {
                operation()
            }
        }

        attempt(0)
    }
    // Improved safeWrite method with error handling
    func safeWrite(_ block: @escaping (Realm) -> Void, completion: ((Bool) -> Void)? = nil) {
        // Ensure that the function is called on the correct thread
        guard let currentThreadRealm = try? Realm() else {
            print("Error while trying to safeWrite to Realm.")
            completion?(false)
            return
        }
        
        self.executeWithRetry {
            if currentThreadRealm.isInWriteTransaction {
                do {
                    try newRealm().write {
                        block(currentThreadRealm)
                    }
                    completion?(true)
                } catch {
                    print("Error while trying to safeWrite to Realm.")
                    completion?(false)
                }
            } else {
                do {
                    try currentThreadRealm.write {
                        block(currentThreadRealm)
                    }
                    completion?(true)
                } catch {
                    print("Error while trying to safeWrite to Realm.")
                    completion?(false)
                }
            }
        }

        
    }
    
    func safeWriteAsync(_ writeBlock: @escaping () -> Void) {
        // Dispatch to a background thread
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    if self.isInWriteTransaction {
                        let realm = try Realm()
                        try realm.write {
                            writeBlock()
                        }
                    } else {
                        try self.write {
                            writeBlock()
                        }
                    }
                } catch {
                    print("Realm write error: \(error)")
                }
            }
        }
    }

}
public enum RealmError: Error {
    case invalidThread
}
public extension Object {
    
    
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
    
    
    func isRealmObjectValid() -> Bool {
        return !self.isInvalidated
    }
    
    func update(block: @escaping (Realm) -> Void) {
        newRealm().safeWrite { r in
            block(r)
            r.invalidate()
        }
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

public extension Dictionary where Key == String, Value == Any {
    
    func toRealmObject<T: Object>(_ type: T.Type, realm: Realm) -> T? {
        var object: T?
        realm.safeWrite { _ in
            object = realm.create(type, value: self, update: .all)
            realm.refresh()
        }
        return object
    }
    
    
    
}
