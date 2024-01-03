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
    
    @State private var emailLogin = ""
    @State private var passLogin = ""
    
    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var arePasswordsMatching: Bool? = nil
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var photoUrl: String = ""
        
    @State var realmInstance = realm()
    @State var isLoading: Bool = false
    @State private var showCompletion = false
    
    @State var isLoginValid = false
    @State private var isUsernameAvailable: Bool? = nil
    @State var keyboardOffset: Double = 0.0

    var body: some View {
        
        if isLoggedIntoFirebase() {
            BuddyProfileView().environmentObject(self.BEO)
        } else {
            LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
                
                VStack(alignment: .leading) {
                    Section(header: Text("User Information")) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 24)
                            .padding(.trailing, 24)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            
                        
                        HStack {
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 24)
                                .padding(.trailing, 24)
                                .onChange(of: username) { newValue in
                                    if newValue.count < 4 {return}
                                    checkUsernameExists(newValue) { result in
                                        if !result {
                                            isUsernameAvailable = true
                                        } else {
                                            isUsernameAvailable = false
                                        }
                                    }
                                }

                            if let isAvailable = isUsernameAvailable {
                                Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isAvailable ? .green : .red)
                                    .padding(.trailing, 10)
                            }
                        }
                        
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 24)
                            .padding(.trailing, 24)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 24)
                            .padding(.trailing, 24)

                        HStack {
                            SecureField("Verify Password", text: $verifyPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 24)
                                .padding(.trailing, 24)
                                .onChange(of: verifyPassword) { newValue in
                                    arePasswordsMatching = (password == newValue)
                                }

                            if let areMatching = arePasswordsMatching {
                                Image(systemName: areMatching ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(areMatching ? .green : .red)
                                    .padding(.trailing, 10)
                            }
                        }
                        
                        
                    }
                }
                
                solButton(title: "Sign Up", action: {
                    runLoading()
                    signUpNewUserInFirebase()
                    self.BEO.loadUser()
                }, isEnabled: isFormValid)
                
                
                Section(header: Text("Login")) {
                    TextField("Email", text: $emailLogin)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 24)
                        .padding(.trailing, 24)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $passLogin)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 24)
                        .padding(.trailing, 24)
                    
                }
                
                solButton(title: "Login", action: {
                    runLoading()
                    loginUser(withEmail: emailLogin, password: passLogin) { result in
                        print("User LogIn: \(result)")
                        self.BEO.loadUser()
                    }
                }, isEnabled: true)
                
                
            }
            .navigationBarTitle("Sign Up/Login")
            
        }
        
    }
    
    func userIsLoggedIn() -> Bool {
        return self.realmInstance.userIsLoggedIn()
    }
    
    private func signUpNewUserInFirebase() {
        signUpWithEmail(email: email, password: password) { result in
            switch result {
            case .success(let authResult):
                print("User signed up successfully: \(authResult.user.email ?? "")")
                let user = authResult.user
                self.BEO.realmInstance.updateGetCurrentSolUser { u in
                    u.userId = user.uid
                    u.userName = username
                    u.email = user.email ?? ""
                    u.imgUrl = user.photoURL?.absoluteString ?? ""
                    u.isLoggedIn = true
                    saveUserToRealtimeDatabase(user: u) { result in
                        print(result)
                    }
                }
  
            case .failure(let error):
                print("Error signing up: \(error.localizedDescription)")
                // Handle error
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
        !username.isEmpty //&& !email.isEmpty && !password.isEmpty && !name.isEmpty
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
