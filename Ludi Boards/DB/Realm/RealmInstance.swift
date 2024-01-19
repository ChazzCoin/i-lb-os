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

func newRealm() -> Realm {
    return RealmInstance.instance
}

func isRealmObjectValid(_ object: Object) -> Bool {
    return !object.isInvalidated
}


func safeAccess<T>(to object: T, action: (T) -> Void) where T: Object {
    guard !object.isInvalidated else {
        print("Object is invalidated.")
        return
    }
    action(object)
}

extension Realm {
    
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
enum RealmError: Error {
    case invalidThread
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
    
    
    func isRealmObjectValid() -> Bool {
        return !self.isInvalidated
    }
    
    func update(block: @escaping (Realm) -> Void) {
        newRealm().safeWrite { r in
            block(r)
            r.invalidate()
        }
    }
    
}


