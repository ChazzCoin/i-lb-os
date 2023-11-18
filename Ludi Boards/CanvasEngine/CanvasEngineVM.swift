//
//  CanvasEngineVM.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import Combine
import SwiftUI



class CanvasEngineViewModel: ObservableObject {
    
    @State var cancellables = Set<AnyCancellable>()
    
    let managedWindowsObject = ManagedViewWindows.shared
    
    func menuBarButtonListener() {
        
        CodiChannel.MENU_TOGGLER.receive(on: RunLoop.main) { buttonType in
            print("Received on MENU_TOGGLER channel: \(buttonType)")
            
            switch MenuBarProvider.parseByTitle(title: buttonType as? String ?? "") {
                case .toolbox: return//toggle
                case .lock: return
                case .canvasGrid: return
                case .navHome: return
                case .boardList: return
                case .boardCreate: return
                case .boardDetails: return
                case .reset: return
                case .trash: return
                case .boardBackground: return
                case .profile: return
                case .share: return
                case .router: return
                case .note: return
                case .chat: return
                
                case .none:
                    return
                case .some(.paint):
                    return
                case .some(.image):
                    return
                case .some(.webBrowser):
                    return
            }
            
        }.store(in: &cancellables)
        
        
    }
}
