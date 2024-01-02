//
//  UserSignUp.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import FirebaseStorage

struct SignUpView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var name = ""
    @State private var password = "" // Assuming you need a password field
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var photoUrl: String = ""
        
    @State var realmInstance = realm()
    @State var isLoading: Bool = false
    @State private var showCompletion = false

    var body: some View {
        
        if self.realmInstance.userIsLoggedIn() {
            BuddyProfileView().environmentObject(self.BEO)
        } else {
            LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                solButton(title: "Sign Up", action: {
                    runLoading()
                    saveUser()
                    self.BEO.loadUser()
                }, isEnabled: isFormValid)
            }
            .navigationBarTitle("Sign Up")
        }
        
    }
    
    func userIsLoggedIn() -> Bool {
        return self.realmInstance.userIsLoggedIn()
    }
    
    private func saveUser() {
        self.BEO.realmInstance.updateGetCurrentSolUser { u in
            u.userId = UUID().uuidString
            u.userName = username
            u.isLoggedIn = true
            saveUserToFirebase(user: u)
        }
        username = ""
    }
    
    private func saveUserToFirebase(user:CurrentSolUser) {
        firebaseDatabase { fdb in
            fdb.child(DatabasePaths.users.rawValue)
                .child(user.id)
                .setValue(user.toDict())
        }
    }
    
    
    private func uploadImageToFirebase(image: UIImage, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("userImages/\(UUID().uuidString).jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(uploadData, metadata: nil) { metadata, error in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        completion(url)
                    })
                }
            }
        }
    }

    var isFormValid: Bool {
        !username.isEmpty //&& !email.isEmpty && !password.isEmpty && !name.isEmpty
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
