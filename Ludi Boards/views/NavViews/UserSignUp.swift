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
    @State var isLoggedIn: Bool = false
    @State private var showCompletion = false
    
    @State var showSignInFailedAlert = false
    
    @State var isLoginValid = false
    @State private var isUsernameAvailable: Bool? = nil
    @State private var isEmailAvailable: Bool? = nil
    @State var keyboardOffset: Double = 0.0
    
    let code = "fair"
    @State private var codeAccepted: Bool? = nil
    @State private var loginCode = ""

    var body: some View {
        
        if self.BEO.isLoggedIn {
            ProfileView()
                .opacity(self.BEO.isLoggedIn ? 1.0 : 0.0)
                .environmentObject(self.BEO)
        } else {
            LoadingForm() { runLoading in
                HStack {
                    SolTextField("Sign-Up Code", text: $loginCode)
                        .padding(.leading)
                        .padding(.trailing)
                        .onChange(of: loginCode) { newValue in
                            if loginCode.lowercased() == code {
                                codeAccepted = true
                            } else {
                                codeAccepted = false
                            }
                        }

                    if let isAvailable = codeAccepted {
                        Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isAvailable ? .green : .red)
                            .padding(.trailing, 10)
                    }
                }
                
                if codeAccepted != nil && codeAccepted == true {
                    VStack() {
                        Section(header: Text("User Sign-Up")) {
                           
                            
                            HStack {
                                SolTextField("Email", text: $email)
                                    .onChange(of: email) { newValue in
                                        if newValue.count < 4 {return}
                                        UserTools.checkEmailExists(newValue) { result in
                                            if !result {
                                                isEmailAvailable = true
                                            } else {
                                                isEmailAvailable = false
                                            }
                                        }
                                    }

                                if let isAvailable = isEmailAvailable {
                                    Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isAvailable ? .green : .red)
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            
                            HStack {
                                SolTextField("Username", text: $username)
                                    .onChange(of: username) { newValue in
                                        if newValue.count < 4 {return}
                                        UserTools.checkUsernameExists(newValue) { result in
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
                            .padding(.leading)
                            .padding(.trailing)
                            
                            SolTextField("Name", text: $name)
                                .padding(.leading)
                                .padding(.trailing)
                            
                            SolTextField("Password", text: $password)
                                .padding(.leading)
                                .padding(.trailing)

                            HStack {
                                SolSecureField("Verify Password", text: $verifyPassword)
                                    .onChange(of: verifyPassword) { newValue in
                                        arePasswordsMatching = (password == newValue)
                                    }

                                if let areMatching = arePasswordsMatching {
                                    Image(systemName: areMatching ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(areMatching ? .green : .red)
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.leading)
                            .padding(.trailing)
                        }
                    }
                    
                    SolButton(
                        title: "Sign Up",
                        action: {
                            runLoading()
                            UserTools.signUp(email: emailLogin, password: passLogin, 
                                onError: { error in
                                    print(error)
                                },
                                onComplete: { fireUser in
                                    print(fireUser)
                                })
                        }, isEnabled: isFormValid
                    ).padding()
                    
                } else {
                
                    // LOGIN !!
                    
                    Text("Welcome to SOL")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .shadow(color: .gray, radius: 2, x: 2, y: 2)
                        .multilineTextAlignment(.center)
                    
                    SolTextField("Email", text: $emailLogin)
                        .padding(.leading)
                        .padding(.trailing)

                    SolSecureField("Password", text: $passLogin)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    SolButton(
                        title: "Login",
                        action: {
                            runLoading()
                            UserTools.login(email: emailLogin, password: passLogin,
                                onResult: { result in
                                    print("User LogIn: \(result)")
                                },
                                onError: { error in
                                    self.showSignInFailedAlert = true
                                })
                        }, isEnabled: true
                    ).padding()
                    
                }
                
            }
            .alert("Login Failed.", isPresented: $showSignInFailedAlert) {
                Button("OK", role: .none) {
                    showSignInFailedAlert = false
                }
            } message: {
                Text("Unable to Login.")
            }
            .navigationBarTitle("Sign Up/Login")
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
//        if self.isUsernameAvailable
        !username.isEmpty
    }
}

