//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI
import RealmSwift


public struct CoreSignUpView: View {
    
    public init() { 
        self.authChanges()
    }
    
    public func authChanges() {
        BroadcastTools.subscribeTo(.authChange) { _ in
            print("Auth Changed!")
            self.resetView()
        }
    }
    
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    
    @State public var username = ""
    @State public var email = ""
    @State public var phone = ""
    @State public var name = ""
    
    @State public var emailLogin = ""
    @State public var passLogin = ""
    
    @State public var password: String = ""
    @State public var verifyPassword: String = ""
    @State public var arePasswordsMatching: Bool? = nil
    @State public var image: UIImage?
    @State public var showImagePicker = false
    @State public var photoUrl: String = ""
        
    public let realmInstance = realm()
    @State public var isLoading: Bool = false
    
    @State public var showCompletion = false
    
    @State public var showSignInFailedAlert = false
    
    @State public var isLoginValid = false
    @State public var isUsernameAvailable: Bool? = nil
    @State public var isEmailAvailable: Bool? = nil
    @State public var keyboardOffset: Double = 0.0
    
    public let code = "fair"
    @State public var codeAccepted: Bool? = nil
    @State public var loginCode = ""
    
    @State public var viewIsResetting = false
    public func resetView() {
        viewIsResetting = true
        viewIsResetting = false
    }

    public var body: some View {
        
        if !viewIsResetting {
            if isLoggedIn {
                CoreProfileView()
            } else {
                LoadingForm { runLoading in
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
                        
                        CoreTextField("Email", text: $emailLogin)
                            .padding(.leading)
                            .padding(.trailing)

                        CoreSecureField("Password", text: $passLogin)
                            .padding(.leading)
                            .padding(.trailing)
                        
                        CoreButton(
                            title: "Login",
                            action: {
                                runLoading()
                                UserTools.login(email: emailLogin, password: passLogin,
                                    onResult: { result in
                                        print("User LogIn: \(result)")
                                        resetView()
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
        
        
        
    }

    public var isFormValid: Bool {
//        if self.isUsernameAvailable
        !username.isEmpty
    }
}
