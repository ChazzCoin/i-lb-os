//
//  RealmChangeListener.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import RealmSwift
import Combine

class RealmChangeListener<T:Object>: ObservableObject {
    private let realmInstance: Realm = realm()
    @Published var notificationToken: NotificationToken?

    func observe(objects: Results<T>, onInitial: @escaping (Array<T>) -> Void={_ in}, onChange: @escaping (Array<T>) -> Void={_ in}) {
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

    
    func observe(object: T, onChange: @escaping (T) -> Void={_ in}, onDelete: @escaping () -> Void={}) {
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
    
    func stop() {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
    }

    deinit {
        notificationToken?.invalidate()
    }
}


class ManagedViewListViewModel: ObservableObject {
    private var realm: Realm = newRealm()
    private var results: Results<ManagedView>
    private var notificationToken: NotificationToken?
    @Published var managedViews = [ManagedView]()

    init() {
        results = realm.objects(ManagedView.self)
        setupChangeListener()
    }

    private func setupChangeListener() {
        
        self.realm.executeWithRetry {
            self.notificationToken = self.results.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }

                switch changes {
                case .initial(let results):
                    // Results are now populated and can be accessed without blocking the UI
                    self.managedViews = Array(results)

                case .update(let results, _, _, _):
                    // Query results have changed
                    self.managedViews = Array(results)

                case .error(let error):
                    print("\(error)")
                    self.notificationToken?.invalidate()
                    self.notificationToken = nil
                }
            }
        }
        
    }

    deinit {
        // Invalidate the notification token when the view model is deinitialized
        notificationToken?.invalidate()
    }
}
