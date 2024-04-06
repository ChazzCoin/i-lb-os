//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation
import RealmSwift


public class RealmChangeListener<T:Object>: ObservableObject {
    public let realmInstance: Realm = realm()
    @Published public var notificationToken: NotificationToken?
    
    public init(notificationToken: NotificationToken? = nil) {
        self.notificationToken = notificationToken
    }

    public func observe(objects: Results<T>, onInitial: @escaping (Array<T>) -> Void={_ in}, onChange: @escaping (Array<T>) -> Void={_ in}) {
        var retryCount = 0

        func attemptObservation() {
            guard let realm = objects.realm, !realm.isInWriteTransaction else {
                // Realm is in a write transaction, retry after a delay
                retryCount += 1
                if retryCount <= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("Realm is in write transaction, attempting to retry observations")
                        attemptObservation()
                    }
                } else {
                    print("Failed to observe Realm objects after 3 retries.")
                }
                return
            }

            // Observe Results Notifications
            self.notificationToken = objects.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch changes {
                        case .initial(let results):
                            onInitial(Array(results))
                        case .update(let results, _, _, _):
                            onChange(Array(results))
                        case .error(let error):
                            print("\(error)")  // Handle errors appropriately in production code
                            self.notificationToken?.invalidate()
                            self.notificationToken = nil
                    }
                }
            }
        }

        attemptObservation()
    }

    
    public func observe(object: T, onChange: @escaping (T) -> Void={_ in}, onDelete: @escaping () -> Void={}) {
        var retryCount = 0
        
        func attemptObservation() {
            guard let realm = object.realm, !realm.isInWriteTransaction else {
                // Realm is in a write transaction, retry after a delay
                retryCount += 1
                if retryCount <= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("Realm is in write transaction, attempting to retry observations")
                        attemptObservation()
                    }
                } else {
                    print("Failed to observe Realm objects after 3 retries.")
                }
                return
            }
            
            
            self.notificationToken = object.observe { [weak self] change in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch change {
                        case .change(let obj, _):
                            if let temp = obj as? T {
                                onChange(temp)
                            }
                        case .deleted:
                            print("Object has been deleted.")
                            onDelete()
                            self.notificationToken?.invalidate()
                            self.notificationToken = nil
                        case .error(let error):
                            print("Error: \(error)")
                            self.notificationToken?.invalidate()
                            self.notificationToken = nil
                        
                    }
                }
            }
        }
        attemptObservation()
    }
    
    public func stop() {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
    }

    deinit {
        notificationToken?.invalidate()
    }
}
