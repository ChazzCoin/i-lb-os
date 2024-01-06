//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct BuddyProfileView: View {
    @State var solUserId: String
    @State var friendStatus: String
    @EnvironmentObject var BEO: BoardEngineObject
    
//    @StateObject var realmObserver = RealmObserver<CurrentSolUser>()
    @State private var realmInstance = realm()
    
    @LiveDataObject(SolUser.self) var solUser
    @LiveDataList(Request.self) var solRequests
    
    @State private var aboutMe: String = "Just enjoying the world of coding and tech!"
    @State private var phoneNumber: String = "123-456-7890"
    @State private var membershipType: Int = 0
    @State private var accountCreationDate: String = "Jan 1, 2020"
    @State private var visibility: String = "closed"
    @State private var photoUrl: String = "default_image_url"
    
    @State private var showNewPlanSheet = false
    @State private var showChatButton = false
    @State private var showAddBuddyButton = false
    @State private var showAcceptBuddyButton = false
    @State private var showShareActivityButton = false
    
    @State private var friends: [SolUser] = []
//    @State private var requests: [Request] = []
    
    var body: some View {
        LoadingForm() { runLoading in
            Group() {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                HStack {
                    Text(solUser?.userName ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Text(solUser?.userId ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(solUser?.email ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                if showAddBuddyButton {
                    Button("Add Buddy") {
                        // Add buddy action
                        showNewPlanSheet = true
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
                if showAcceptBuddyButton {
                    Button("Accept Buddy Request") {
                        // Add buddy action
                        showNewPlanSheet = true
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
            }
            .padding(.bottom, 20)
        }
        .refreshable {
            loadUser()
            loadFriendRequests()
        }
        .onAppear() {
            loadUser()
            loadFriendRequests()
            
            switch (friendStatus) {
                case "pending": self.showAcceptBuddyButton = true
                case "friends":  self.showAddBuddyButton = false
                default: self.showAddBuddyButton = true
            }
            
            if friendStatus == "pending" {
                self.showAddBuddyButton = true
            }
            
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            AddBuddyView(isPresented: $showNewPlanSheet)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile action
                }
            }
        }
    }
    
    func loadFriendRequests() {
        
    }
    
    func loadUser() {
        _solUser.load(field: "userId", value: self.solUserId)
        _solUser.startFirebaseObservation() { db in
            return db.child("users").child(self.solUserId)
        }
//        fireGetSolUserAsync(userId: self.solUserId, realm: self.realmInstance)
    }
    
    private func profileInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title + ":")
                .font(.headline)
            Text(value)
                .font(.body)
            Divider()
        }
    }
}


struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

//struct BuddyProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuddyProfileView()
//    }
//}
