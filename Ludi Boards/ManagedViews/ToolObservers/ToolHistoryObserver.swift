//
//  ToolHistoryObserver.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import CoreEngine

@available(*, deprecated, renamed: "ObservedResults", message: "Use ObservedResults Instead.")
class ToolHistoryObserver : ObservableObject {
    @EnvironmentObject var BEO: BoardEngineObject
    @Published var historyNotificationToken: NotificationToken? = nil
    
    private func startHistoryObserver() {
        // Realm
        let umvs = self.BEO.realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.BEO.currentActivityId)
        
        self.BEO.realmInstance.executeWithRetry {
            print("Starting Recording Listener")
            self.historyNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
                DispatchQueue.main.async {
                    switch changes {
                        case .initial(let results):
                            print("History Listener: initial")
                            for i in results {
                                if i.isInvalidated {continue}
                                // Initial State
                                let newAction = RecordingAction()
                                newAction.recordingId = self.BEO.currentRecordingId
                                newAction.isInitialState = true
                                newAction.absorb(from: i)
                                self.BEO.realmInstance.safeWrite { r in
                                    r.create(RecordingAction.self, value: newAction, update: .all)
                                }
                            }
                        case .update(let results, _, _, let modifications):
                            print("History Listener: update")
                            for index in modifications {
                                let modifiedObject = results[index]
                                let newAction = RecordingAction()
                                newAction.absorb(from: modifiedObject)
                                self.BEO.realmInstance.safeWrite { r in
                                    r.create(RecordingAction.self, value: newAction, update: .all)
                                }
                            }
                        case .error(let error):
                            print("History Listener: \(error)")
                            self.historyNotificationToken?.invalidate()
                            self.historyNotificationToken = nil
                    }
                }
                
            }
        }
    }
}
