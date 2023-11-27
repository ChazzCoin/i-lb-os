//
//  FirebaseLogin.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
//import FirebaseUI

//struct FirebaseUILoginView: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//
//    func makeUIViewController(context: Context) -> UINavigationController {
//        let authUI = FUIAuth.defaultAuthUI()
//        authUI?.delegate = context.coordinator
//
//        let providers: [FUIAuthProvider] = [
//            FUIGoogleAuth(),
//            FUIEmailAuth()
//        ]
//        authUI?.providers = providers
//
//        let authViewController = authUI!.authViewController()
//        return authViewController
//    }
//
//    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, FUIAuthDelegate {
//        var parent: FirebaseUILoginView
//
//        init(_ parent: FirebaseUILoginView) {
//            self.parent = parent
//        }
//
//        func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
//            // Handle user sign-in or error
//            if let error = error {
//                print("Error during FirebaseUI login: \(error.localizedDescription)")
//                return
//            }
//
//            if let user = user {
//                print("User signed in: \(user.email ?? "Unknown Email")")
//                // Navigate away from the login view or update the state
//                parent.presentationMode.wrappedValue.dismiss()
//            }
//        }
//    }
//}
