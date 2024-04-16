//
//  WrldsApp.swift
//  Wrlds
//
//  Created by Charles Romeo on 12/22/23.
//

import SwiftUI
import FirebaseCore
import RealmSwift
import CoreEngine

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct WrldsApp: SwiftUI.App {
    @StateObject private var viewModel = ARViewModel()
    init() {
        let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup(id: "arkit") {
            ZStack(alignment: .bottom) {
                ARViewContainer(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    

                if let position = viewModel.buttonPosition {
                    Button(action: {
                        // Perform an action
                    }) {
                        Text("Tap Me")
                            .frame(width: 100, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .position(position)
                }
            }
        }
        
//        WindowGroup(id: "canvas") {
////            CoreCanvasEngine(
////                global: { _,_ in
////                    
////                },
////                canvas: { gps in
////                    ZStack{
////                        Text("HELLO")
////                    }
////                    .frame(width: 200, height: 200)
////                    .background(.blue)
////                    .position(using: gps, at: .bottomCenter)
////                })
//            CanvasEngine().onAppear() {
//                
//            }
//        }
    }
}
