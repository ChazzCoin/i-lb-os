//
//  LoginView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    var onResult: (Bool) -> Void = { _ in }
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()

            // App icon
            Image("sol_icon") // Replace with your app's icon
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 50)

            // Username text field
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            // Password text field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
                .padding(.top, 20)

            // Login button
            Button(action: {
                // Handle login action
                
            }) {
                Text("Log In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
            }

            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
