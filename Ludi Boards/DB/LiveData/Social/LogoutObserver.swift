//
//  LogoutObserver.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/8/24.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine

class LogoutObserver : ObservableObject {
    @Published var cancellables = Set<AnyCancellable>()
    @Published var logoutHasBeenCalled = false
    @Published var loginHasBeenCalled = false
    @Published var onLogout: () -> Void = {}
    @Published var onLogin: () -> Void = {}
    
    init() {
        CodiChannel.ON_LOG_IN_OUT.receive(on: RunLoop.main) { result in
            let temp = result as! String
            print("LOGOUT INIT: LogoutObserver = [ \(temp) ]")
            if "logout" == temp {
                if self.logoutHasBeenCalled == true {
                    return
                }
                self.logoutHasBeenCalled = true
                self.onLogout()
            } else if "login" == temp {
                if self.loginHasBeenCalled == true {
                    return
                }
                self.loginHasBeenCalled = true
                self.onLogin()
            }
        }.store(in: &cancellables)
    }
    
    func destroy() {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()

            // Optionally reset states
            logoutHasBeenCalled = false
            loginHasBeenCalled = false
        }
}
