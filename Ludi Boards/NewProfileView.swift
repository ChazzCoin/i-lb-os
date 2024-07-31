//
//  NewProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 6/4/24.
//

import Foundation
import SwiftUI

struct NewProfileView: View {
    var body: some View {
        VStack(spacing: 0) {
            ProfileScreenLeft()
            BottomNavigationBar()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ProfileScreenLeft: View {
    var body: some View {
        VStack {
            Image("profile_photo") // Replace with your image asset
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipped()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("2.8k")
                        .font(.headline)
                    Text("followers")
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("346")
                        .font(.headline)
                    Text("posts")
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("845")
                        .font(.headline)
                    Text("following")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text("Christine Wallace")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Follow action
                }) {
                    Text("FOLLOW")
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}
struct ProfileScreenRight: View {
    var body: some View {
        VStack {
            Image("profile_small") // Replace with your image asset
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("869")
                        .font(.headline)
                    Text("followers")
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("135")
                        .font(.headline)
                    Text("posts")
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("485")
                        .font(.headline)
                    Text("following")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Lori Perez")
                    .font(.headline)
                Text("France, Nantes")
                    .font(.subheadline)
                Button(action: {
                    // Follow action
                }) {
                    Text("FOLLOW")
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                Text("Photoreporter at 'Le Monde'; blogger and freelance journalist")
                    .font(.body)
                    .padding(.top, 4)
                
                // Photo grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<4) { _ in
                            Image("photo") // Replace with your image asset
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct BottomNavigationBar: View {
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Home action
            }) {
                Image(systemName: "house.fill")
                    .font(.title)
            }
            Spacer()
            Button(action: {
                // Search action
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title)
            }
            Spacer()
            Button(action: {
                // Add action
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            Spacer()
            Button(action: {
                // Notifications action
            }) {
                Image(systemName: "bell.fill")
                    .font(.title)
            }
            Spacer()
            Button(action: {
                // Profile action
            }) {
                Image(systemName: "person.fill")
                    .font(.title)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
    }
}
