//
//  WrldsApp.swift
//  Wrlds
//
//  Created by Charles Romeo on 12/22/23.
//

import SwiftUI
import FirebaseCore
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct WrldsApp: SwiftUI.App {
    
    init() {
        let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            CanvasEngine().onAppear() {
                
            }
        }
    }
}
