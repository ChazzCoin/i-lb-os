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
        
//    @State var isLoggedIn: Bool = false
    @State var isLoading: Bool = false
    @State private var showCompletion = false

    var body: some View {
        
        if self.BEO.isLoggedIn {
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
    
    private func saveUser() {
        let newUser = SolKnight()
        newUser.tempId = UUID().uuidString
        newUser.username = username
        
        self.BEO.realmInstance.safeWrite { r in
            r.add(newUser)
        }
        
        saveSolKnightToFirebase(user: newUser)
        username = ""
//        newUser.email = email
//        newUser.phone = phone
//        newUser.name = name        
        // Check if there is an image selected
//        if let selectedImage = self.image {
//            // Upload to Firebase Storage
//            uploadImageToFirebase(image: selectedImage) { url in
//                newUser.photoUrl = url?.absoluteString ?? ""
//                // Save user to Realm with photo URL
//                try! realmInstance.write {
//                    realmInstance.add(newUser)
//                }
//            }
//        } else {
//            // Save user to Realm without photo URL
//            try! realmInstance.write {
//                realmInstance.add(newUser)
//            }
//        }
        
        
        
    }
    
    private func saveUserToFirebase(user:User) {
        firebaseDatabase { fdb in
            fdb.child(DatabasePaths.users.rawValue)
                .child(user.id)
                .setValue(user.toDict())
        }
    }
    
    private func saveSolKnightToFirebase(user:SolKnight) {
        firebaseDatabase { fdb in
            fdb.child(DatabasePaths.users.rawValue)
                .child(user.tempId)
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
