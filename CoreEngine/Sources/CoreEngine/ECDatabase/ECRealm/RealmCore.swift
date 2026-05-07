//
//  RealmInstance.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/24/23.
//

import Foundation
import RealmSwift
import Realm

/*
    DO NOT MODIFY THIS FUCKING FILE.
 
        PERIOD.
 
            DO NOT TOUCH IT.
 
                GO AWAY.
 */

func serializeArray<T: Encodable>(_ array: [T]) throws -> String {
    let data = try JSONEncoder().encode(array)
    return String(data: data, encoding: .utf8) ?? "[]"
}
func deserializeArray<T: Decodable>(_ string: String, as type: T.Type) throws -> [T] {
    let data = Data(string.utf8)
    return try JSONDecoder().decode([T].self, from: data)
}



public class RealmInstance {
    static let instance: Realm = { return try! Realm() }()
}

public enum RealmError: Error {
    case invalidThread
}

// MARK: Base Realm GETTER
public func realm() -> Realm { return RealmInstance.instance }
public func newRealm() -> Realm { return RealmInstance.instance }
public func isRealmObjectValid(_ object: Object) -> Bool { return !object.isInvalidated }

public func realmWriter(_ realm: Realm = newRealm(), action: @escaping (Realm) -> Void) {
    realm.safeWrite { r in action(r) }
}


public func safeAccess<T>(to object: T, action: (T) -> Void) where T: Object {
    guard !object.isInvalidated else {
        print("Object is invalidated.")
        return
    }
    action(object)
}

public func getPrimaryKey<T: Object>(_ item: T, defaultValue:String="") -> String {
    if let primaryKeyProperty = T.primaryKey(), let primaryKeyValue = item.value(forKey: primaryKeyProperty) as? String {
        return primaryKeyValue
    }
    return defaultValue
}


// MARK: Base Realm Extentions
public extension Realm {
    
    func objects<T: Object, String>(_ type: T.Type, in ids: [String]) -> Results<T> where String: _Persistable {
        return objects(type).filter("id IN %@", ids)
    }
    func objects<T: Object, String>(_ type: T.Type, notIn ids: [String]) -> Results<T> where String: _Persistable {
        return objects(type).filter("NOT id IN %@", ids)
    }
    func findInListOfIds<T: Object>(_ type: T.Type, in ids: [String]) -> Results<T> {
        return objects(type).filter("id IN %@", ids)
    }
    func findNotInListOfIds<T: Object>(_ type: T.Type, in ids: [String]) -> Results<T> {
        return objects(type).filter("NOT id IN %@", ids)
    }
    
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

// MARK: Base Results Extentions
public extension Results {
    
    func toArray() -> [Element] {
        return Array(self)
    }
    
    func toRealmList<T: Object>() -> List<T> {
        let list = List<T>()
        realmWriter { r in
            self.forEach { result in
                // Ensure the result is of the expected type before adding it to the list
                if let result = result as? T {
                    list.append(result)
                }
            }
        }
        return list
    }
}

// MARK: Base Object Extentions
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
    // Convert to dictionary
   func toDict() -> [String: Any] {
       let properties = self.objectSchema.properties.filter {
           if let objectType = $0.objectClassName, objectType.contains("LinkingObjects<") {
               return false // Exclude LinkingObjects properties
           }
           return !$0.name.hasPrefix("linked") // Additionally exclude properties starting with "linked"
       }.map { $0.name }

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
    
    func getPrimaryKey<T: Object>(_ type: T.Type, defaultValue:String="") -> String {
        if let primaryKeyProperty = T.primaryKey(), let primaryKeyValue = self.value(forKey: primaryKeyProperty) as? String {
            return primaryKeyValue
        }
        return defaultValue
    }
    
    func absorbProperties(from sourceModel: Object) {
        let schema = sourceModel.objectSchema
        for property in schema.properties {
            guard let value = sourceModel.value(forKey: property.name) else {
                self.setValue(nil, forKey: property.name)
                continue
            }
            
            switch property.type {
            case .int, .string, .bool:
                self.setValue(value, forKey: property.name)
            default:
                break
            }
        }
    }
    
    func getId() -> String? {
        return self.value(forKey: "id") as? String
    }
    func getField<T>(_ fieldName: String) -> T? {
        return self.value(forKey: fieldName) as? T
    }
    func safeCreate<T: Object>(_ type: T.Type) {
        newRealm().safeWrite { r in
            r.create(type, value: self, update: .all)
            r.refresh()
        }
    }
    
    func safeDelete() {
        newRealm().safeWrite { r in
            r.delete(self)
        }
    }

}

// MARK: Base Realm/Dictionary/Parsing Extentions
public extension Dictionary where Key == String, Value == Any {
    
    @available(*, deprecated, renamed: "toCoreObject", message: "Please stop using this.")
    func toRealmObject<T: Object>(_ type: T.Type, realm: Realm) -> T? {
        var object: T?
        realm.safeWrite { _ in
            object = realm.create(type, value: self, update: .all)
            realm.refresh()
        }
        return object
    }
    func toCoreObject<T: Object>(_ type: T.Type, realm: Realm) -> T? {
        var object: T?
        realm.safeWrite { _ in
            print("adding new object of type: [\(type)]")
            object = realm.create(type, value: self, update: .all)
            realm.refresh()
        }
        return object
    }
}
