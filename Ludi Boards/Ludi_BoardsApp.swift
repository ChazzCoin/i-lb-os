//
//  Ludi_BoardsApp.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/10/23.
//

import SwiftUI
import Combine

@main
struct Ludi_BoardsApp: App {
    
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some Scene {
        WindowGroup {
            CanvasEngine().onAppear {
                print("Waiting...")
                CodiChannel.general.receive(on: RunLoop.main) { message in
                    print("Received on general channel: \(message)")
                }.store(in: &cancellables)
            }
                
        }
    }
}
