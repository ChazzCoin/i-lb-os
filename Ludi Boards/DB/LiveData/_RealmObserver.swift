//
//  RealmObserver.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/4/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

@available(*, deprecated, renamed: "ObservedResults", message: "Migrated to Observed Results.")
class RealmObserver<T:Object>: ObservableObject {
    @Published var realmInstance: Realm = realm()
    private var nofityToken: NotificationToken? = nil
    
    func observeId(id: String, onInitial: @escaping (T) -> Void={ _ in }, onChange: @escaping (T) -> Void) {
        
        self.realmInstance.executeWithRetry {
            if let mv = self.realmInstance.object(ofType: T.self, forPrimaryKey: id) {
                onInitial(mv)
                self.nofityToken = mv.observe { change in
                    switch change {
                        case .change(let obj, _):
                            let temp = obj as! T
                            onChange(temp)
                        case .error(let error):
                            print("Error: \(error)")
                            self.nofityToken?.invalidate()
                            self.nofityToken = nil
                        case .deleted:
                            print("Object has been deleted.")
                            self.nofityToken?.invalidate()
                            self.nofityToken = nil
                    }
                }
            }
        }

    }
    
    deinit{
        nofityToken?.invalidate()
    }
}
