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

@available(*, deprecated, renamed: "ObservedResults", message: "Replaced for Observed Results")
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
