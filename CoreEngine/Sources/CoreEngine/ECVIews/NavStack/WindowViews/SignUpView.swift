//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI



public struct CoreSignUpView: View {
    
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    
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
    
    @State var showSignInFailedAlert = false
    
    @State var isLoginValid = false
    @State private var isUsernameAvailable: Bool? = nil
    @State private var isEmailAvailable: Bool? = nil
    @State var keyboardOffset: Double = 0.0
    
    let code = "fair"
    @State private var codeAccepted: Bool? = nil
    @State private var loginCode = ""

    public var body: some View {
        
        if UserTools.isLoggedIn {
            EmptyView()
//            ProfileView()
//                .opacity(self.isLoggedIn ? 1.0 : 0.0)
        } else {
            Form { //runLoading in
                HStack {
                    CoreTextField("Sign-Up Code", text: $loginCode)
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
                                CoreTextField("Email", text: $email)
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
                                CoreTextField("Username", text: $username)
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
                            
                            CoreTextField("Name", text: $name)
                                .padding(.leading)
                                .padding(.trailing)
                            
                            CoreTextField("Password", text: $password)
                                .padding(.leading)
                                .padding(.trailing)

                            HStack {
                                CoreSecureField("Verify Password", text: $verifyPassword)
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
                    
                    CoreButton(
                        title: "Sign Up",
                        action: {
//                            runLoading()
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
                    
                    CoreTextField("Email", text: $emailLogin)
                        .padding(.leading)
                        .padding(.trailing)

                    CoreSecureField("Password", text: $passLogin)
                        .padding(.leading)
                        .padding(.trailing)
                    
//                    CoreButton(
//                        title: "Login",
//                        action: {
//                            runLoading()
//                            UserTools.login(email: emailLogin, password: passLogin,
//                                onResult: { result in
//                                    print("User LogIn: \(result)")
//                                },
//                                onError: { error in
//                                    self.showSignInFailedAlert = true
//                                })
//                        }, isEnabled: true
//                    ).padding()
                    
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

    var isFormValid: Bool {
//        if self.isUsernameAvailable
        !username.isEmpty
    }
}
