//
//  Ludi_BoardsApp.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/10/23.
//

import SwiftUI
import Combine
import RealmSwift
import Firebase
import CoreEngine

@main
struct LudiBoardsApp: SwiftUI.App {
    
    @State var cancellables = Set<AnyCancellable>()
    
    init() {
        // Bump schemaVersion whenever a @Persisted model changes; additive
        // changes migrate automatically. Never wipe user boards on update.
        let realmConfiguration = Realm.Configuration(
            // v2 (RD-5): additive — ManagedView gains playerId/jerseyNumber/
            // teamSide + the new RosterPlayer model. Additive changes migrate
            // automatically; a future NON-additive change (rename/remove/retype)
            // must populate this block with explicit oldObject/newObject mapping
            // or Realm throws at launch (TASK-024).
            // v3 (AN phase): additive — RecordingAction gains timeOffset,
            // actionType, subToolType, playerId, jerseyNumber, teamSide for
            // faithful, timed, seek-able replay. Additive migrates automatically.
            schemaVersion: 3,
            migrationBlock: { _, _ in }
        )
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // RD-6 cutover (TASK-012): the redesigned board is the live board.
            // The legacy `CanvasEngine` stays in the codebase, reachable for QA
            // via a DEBUG env var, until it's fully removed.
            #if DEBUG
            if ProcessInfo.processInfo.environment["LEGACY_BOARD"] == "1" {
                CanvasEngine()
            } else {
                RedesignRootView()
            }
            #else
            RedesignRootView()
            #endif
//            temp.onAppear() {
//                
//                delayThenMain(15, mainBlock: {
//                    if let img = ImageRenderer(content: temp).cgImage {
//                        let result = CoreFiles.saveImageToDocuments(image: UIImage(cgImage: img), withName: "temp.jpg")
//                        print("Image was saved: [\(result)]")
//                    }
//                })
//               
//            }
            
            
        }
    }
}
