//
//  RealmObserver.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/4/24.
//

import Foundation
import SwiftUI
import RealmSwift

class RealmObserver<T:Object>: ObservableObject {
    @Published var realmInstance: Realm = realm()
    private var nofityToken: NotificationToken? = nil
    
    func observeId(id: String, onInitial: (T) -> Void={ _ in }, onChange: @escaping (T) -> Void) {
        if let mv = realmInstance.object(ofType: T.self, forPrimaryKey: id) {
            onInitial(mv)
            nofityToken = mv.observe { change in
                switch change {
                    case .change(let obj, _):
                        let temp = obj as! T
                        onChange(temp)
                    case .error(let error):
                        print("Error: \(error)")
                    case .deleted:
                        print("Object has been deleted.")
                }
            }
        }

    }
    
    deinit{
        nofityToken?.invalidate()
    }
}
