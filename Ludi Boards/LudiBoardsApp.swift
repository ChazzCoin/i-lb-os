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
        let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = realmConfiguration
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            let temp = CanvasEngine()
            temp.onAppear() {
                
                delayThenMain(15, mainBlock: {
                    if let img = ImageRenderer(content: temp).cgImage {
                        let result = CoreFiles.saveImageToDocuments(image: UIImage(cgImage: img), withName: "temp.jpg")
                        print("Image was saved: [\(result)]")
                    }
                })
               
            }
            
            
        }
    }
}
