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
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var name = ""
    @State private var password = "" // Assuming you need a password field
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var photoUrl: String = ""

    let realmInstance = realm()
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Name", text: $name)
                
                // Image Picker Section
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .onTapGesture {
                            self.showImagePicker = true
                        }
                } else {
                    Button("Pick Image") {
                        self.showImagePicker = true
                    }
                }
            }

            Section(header: Text("Security")) {
                SecureField("Password", text: $password)
            }

            Button("Sign Up") {
                saveUser()
            }
            .disabled(!isFormValid)
        }
        .navigationBarTitle("Sign Up")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    private func saveUser() {
        let newUser = User()
        newUser.id = UUID().uuidString // Generating a unique ID
        newUser.username = username
        newUser.email = email
        newUser.phone = phone
        newUser.name = name        
        // Check if there is an image selected
        if let selectedImage = self.image {
            // Upload to Firebase Storage
            uploadImageToFirebase(image: selectedImage) { url in
                newUser.photoUrl = url?.absoluteString ?? ""
                // Save user to Realm with photo URL
                try! realmInstance.write {
                    realmInstance.add(newUser)
                }
            }
        } else {
            // Save user to Realm without photo URL
            try! realmInstance.write {
                realmInstance.add(newUser)
            }
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
        !username.isEmpty && !email.isEmpty && !password.isEmpty && !name.isEmpty
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
