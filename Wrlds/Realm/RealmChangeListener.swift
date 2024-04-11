//
//  RealmChangeListener.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import RealmSwift
import Combine
import CoreEngine

class ManagedViewListViewModel: ObservableObject {
    private var realm: Realm
    private var results: Results<ManagedView>
    private var notificationToken: NotificationToken?
    @Published var managedViews = [ManagedView]()

    init() {
        // Initialize Realm and Results
        realm = try! Realm()  // Handle this safely in production code
        results = realm.objects(ManagedView.self)

        setupChangeListener()
    }

    private func setupChangeListener() {
        // Observe Results Notifications
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }

            switch changes {
            case .initial(let results):
                // Results are now populated and can be accessed without blocking the UI
                self.managedViews = Array(results)

            case .update(let results, _, _, _):
                // Query results have changed
                self.managedViews = Array(results)

            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")  // Handle errors appropriately in production code
            }
        }
    }

    deinit {
        // Invalidate the notification token when the view model is deinitialized
        notificationToken?.invalidate()
    }
}
