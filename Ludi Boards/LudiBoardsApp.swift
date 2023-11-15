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

@main
struct LudiBoardsApp: SwiftUI.App {
    
    @State var cancellables = Set<AnyCancellable>()
    
    init() {
        let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
        
        fireManagedViewsAsync(boardId: "boardEngine-1", realm: realm())
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                CanvasEngine()
                    .onAppear {
                        print("Waiting...")
                        CodiChannel.general.receive(on: RunLoop.main) { message in
                            print("Received on general channel: \(message)")
                        }.store(in: &cancellables)
                }
                
                MenuBarWindow(items: [
                    {MenuButtonIcon(icon: MenuBarProvider.toolbox)},
                    {MenuButtonIcon(icon: MenuBarProvider.lock)}
                ])
//                MenuBarFloatingWindow {
//                    
//                }
            }
            
                
        }
    }
}
